import 'dart:async';
import 'dart:convert';
import 'package:open_core/core.dart';
import 'package:open_core/src/api/auth/user_adapater.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Mixin that implements authentication functionality.
/// This mixin provides methods for user authentication, session management,
/// and secure storage of user data.
mixin Authentication implements ApiAuth {
  late final Box<User> _userBox;
  final _userKey = "user-key";
  final _userBoxName = "user";
  final _secureStorage = const FlutterSecureStorage();
  final _aOptions = const AndroidOptions(encryptedSharedPreferences: true);
  final _iOptions =
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  /// Initializes the authentication system.
  /// This method sets up Hive for storing user data and initializes the encrypted user box.
  Future<void> initAuth() async {
    logger.i("INIT AUTH EXENSIONS");
    Hive.registerAdapter(UserAdapter());
    _userBox =
        await _initCryptBox<User>(keyFor: _userKey, boxName: _userBoxName);
  }

  /// Initializes an encrypted Hive box for secure storage.
  ///
  /// [keyFor] is the key used to store the encryption key in secure storage.
  /// [boxName] is the name of the Hive box to be created.
  ///
  /// Returns a Future that resolves to the initialized Box<T>.
  Future<Box<T>> _initCryptBox<T>(
      {required String keyFor, required String boxName}) async {
    try {
      // cryptkey stored in the device specific encrypted storage (IOS: keychain, Andriod: AES encrypt.)
      // the cryptkey is used as cipher for the Hive key value store, to encrypt all offline stored data
      // boxes are created an encrypted on app start up, Hive boxes and securestorage is flushed and cleared
      // on logout
      var cryptKey = await _secureStorage.read(
          key: keyFor, aOptions: _aOptions, iOptions: _iOptions);

      cryptKey ??= await _createCryptKey(keyFor: keyFor);

      return await Hive.openBox<T>(boxName,
          encryptionCipher: HiveAesCipher(base64Url.decode(cryptKey)));
    } catch (e) {
      logger.e(
          "Something went wrong setting up the crypt box for: $keyFor box $boxName");
      throw Exception("Could not setup crypt box, for $boxName! See $e");
    }
  }

  /// Creates a new encryption key and stores it in secure storage.
  ///
  /// [keyFor] is the key under which the encryption key will be stored.
  ///
  /// Returns a Future that resolves to the base64 encoded encryption key.
  Future<String> _createCryptKey({required String keyFor}) async {
    final key = Hive.generateSecureKey();
    await _secureStorage.write(
        key: keyFor,
        value: base64UrlEncode(key),
        aOptions: _aOptions,
        iOptions: _iOptions);
    return base64UrlEncode(key);
  }

  /// Retrieves the current user from storage.
  ///
  /// Returns the current User object, or null if no user is logged in.
  User? getUser() {
    final res = _userBox.get("current");
    logger.i("get user $res");
    return res;
  }

  /// Logs out the current user and performs cleanup.
  ///
  /// [onLogout] is an optional callback function to be called after logout.
  Future<void> logout({Function? onLogout}) async {
    try {
      await deleteSession(sessionId: "current");
    } catch (e) {
      logger.e("Error during logout, see $e");
    }
    await logOutCleanUp();

    if (onLogout != null) {
      onLogout();
    }
  }

  /// Performs cleanup operations after logout.
  /// This includes clearing user data and removing stored credentials.
  FutureOr<void> logOutCleanUp() async {
    try {
      final currentUser = getUser();
      if (currentUser != null) {
        await Future.wait([
          _userBox.clear(),
          _secureStorage.delete(
              key: currentUser.email, iOptions: _iOptions, aOptions: _aOptions),
          _secureStorage.delete(
              key: _userKey, iOptions: _iOptions, aOptions: _aOptions)
        ]);
      }
    } catch (e) {
      logger.e("Error on logout clean up, $e");
    }
  }

  /// Initiates OAuth login with the specified provider.
  ///
  /// [provider] is the name of the OAuth provider to use.
  ///
  /// This method is not implemented and will throw an UnimplementedError.
  Future oAuthLogin(String provider) {
    throw UnimplementedError();
  }

  /// Performs user login with email and password.
  ///
  /// [email] is the user's email address.
  /// [password] is the user's password.
  ///
  /// Returns a Future that resolves to the logged-in User object, or null if login fails.
  Future<User?> login({required String email, required String password}) async {
    await _userBox.clear();
    logger.i("LOGIN $email");
    try {
      final cacheUser = await createSession(email: email, password: password);
      // save pw for cached-login
      await _secureStorage.write(
          key: cacheUser.email,
          value: password,
          iOptions: _iOptions,
          aOptions: _aOptions);
      await _userBox.put("current", cacheUser);
      logger.i("completed login");
      return cacheUser;
    } on Exception catch (e) {
      logger.w("Something went wrong on login $e");
      return null;
    }
  }

  /// Attempts to log in using cached credentials.
  ///
  /// Returns a Future that resolves to the logged-in User object, or null if login fails.
  /// Throws an exception if no cached user or password is found.
  Future<User?> cachedLogin() async {
    logger.i("trying cached login!");
    final currentUser = getUser();

    if (currentUser == null) {
      throw Exception("Cannot do a cached login without a current User!");
    }

    try {
      await deleteSession(sessionId: "current");
    } catch (e) {
      logger.e("Error during session delete, see $e");
    }

    final pw = await _secureStorage.read(
        key: currentUser.email, iOptions: _iOptions, aOptions: _aOptions);

    if (pw == null) {
      throw Exception("Cannot do a cached login without a pw!");
    }

    return await login(email: currentUser.email, password: pw);
  }

  /// Refreshes the current session.
  ///
  /// [sessionId] is the ID of the session to refresh (currently unused).
  ///
  /// This method is intended for OAuth sessions and calls updateSession.
  Future<User?> refreshSession(String sessionId) async {
    /// oauth only

    // await _userBox.clear();
    logger.i("Refresh session");
    try {
      final cacheUser = await updateSession(sessionId: "current");
      if (cacheUser == null) {
        return null;
      }
      await _userBox.put("current", cacheUser);
      logger.i("completed refresh");
      return cacheUser;
    } on Exception catch (e) {
      logger.w("Something went wrong on login $e");
      return null;
    }
  }

  /// Creates a new user account.
  ///
  /// [email] is the email address for the new account.
  /// [password] is the password for the new account.
  /// [name] is the name of the user.
  ///
  /// TODO: add a Map to signup wit more info then email and name
  Future signup(
      {required String email,
      required String password,
      required String name}) async {
    await createAccount(email: email, password: password, name: name);
  }

  /// Clears all locally stored user data.
  Future<void> clear() async {
    await _userBox.clear();
  }


}
