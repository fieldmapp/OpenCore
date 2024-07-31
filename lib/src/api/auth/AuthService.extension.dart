import 'dart:convert';
import 'package:open_core/core.dart';
import 'package:open_core/src/api/auth/user_adapater.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

mixin Authentication implements ApiAuth {
  late final Box<User> _userBox;
  final _userKey = "user-key";
  final _userBoxName = "user";
  final _secureStorage = const FlutterSecureStorage();
  final _aOptions = const AndroidOptions(encryptedSharedPreferences: true);
  final _iOptions =
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  Future<void> initAuth() async {
    logger.i("INIT AUTH EXENSIONS");
    Hive.registerAdapter(UserAdapter());
    _userBox =
        await _initCryptBox<User>(keyFor: _userKey, boxName: _userBoxName);
    final u = _userBox.toMap();
    logger.i(u);
  }

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

  Future<String> _createCryptKey({required String keyFor}) async {
    final key = Hive.generateSecureKey();
    await _secureStorage.write(
        key: keyFor,
        value: base64UrlEncode(key),
        aOptions: _aOptions,
        iOptions: _iOptions);
    return base64UrlEncode(key);
  }

  User? getUser() {
    final res = _userBox.get("current");
    logger.i("get user $res");
    return res;
  }

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

  /// clears the userbox as well as the credentials from the securestorage
  Future logOutCleanUp() async {
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

  Future oAuthLogin(String provider) {
    throw UnimplementedError();
  }

  Future<void> login({required String email, required String password}) async {
    await _userBox.clear();
    logger.i("LOGIN $email");

    // final session =
    //     await account.createEmailSession(email: email, password: password);
    // final user = await account.get();

    // // time stamp of expirey in UTC
    // final expire = DateTime.parse(session.expire);
    // final cacheUser =
    //     User(user.name, user.email, expire.millisecondsSinceEpoch);
    final cacheUser = await createSession(email: email, password: password);
    // save pw for cached-login
    await _secureStorage.write(
        key: email, value: password, iOptions: _iOptions, aOptions: _aOptions);
    await _userBox.put("current", cacheUser);
    logger.i("completed login");
  }

  Future cachedLogin() async {
    logger.i("trying cached login!");
    final currentUser = getUser();

    if (currentUser == null) {
      throw Exception("Cannot do a cached login whithout a current User!");
    }

    try {
      await deleteSession(sessionId: "current");
    } catch (e) {
      logger.e("Error during session delete, see $e");
    }
    // todo delete old session
    final pw = await _secureStorage.read(
        key: currentUser.email, iOptions: _iOptions, aOptions: _aOptions);
    await login(email: currentUser.email, password: pw!);
  }

  Future refreshSession(String sessionId) async {
    /// oauth only
    await updateSession(sessionId: "current");
  }

  Future signup(
      {required String email,
      required String password,
      required String name}) async {
    await createAccount(email: email, password: password, name: name);
  }
}
