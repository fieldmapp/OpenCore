part of core;

/// Abstract class defining the authentication API interface.
/// This class provides the basic structure for authentication operations
/// and logging functionality.
abstract class ApiAuth {
  /// Logger instance for debugging and error reporting.
  final logger = Logger();

  /// Initializes the authentication system.
  /// This method should be implemented to set up any necessary
  /// configurations or dependencies for the authentication process.
  Future<void> init();

  /// Deletes a user session.
  ///
  /// [sessionId] is the unique identifier for the session to be deleted.
  @protected
  Future deleteSession({required String sessionId});

  /// Updates a user session.
  ///
  /// [sessionId] is the unique identifier for the session to be updated.
  @protected
  Future<User?> updateSession({required String sessionId});

  /// Creates a new user session (logs in a user).
  ///
  /// [email] is the user's email address.
  /// [password] is the user's password.
  ///
  /// Returns a Future that resolves to a User object representing the logged-in user.
  @protected
  Future<User> createSession({required String email, required String password});

  /// Creates a new user account.
  ///
  /// [email] is the email address for the new account.
  /// [password] is the password for the new account.
  /// [name] is the name of the user.
  @protected
  Future createAccount(
      {required String email, required String password, required String name});
}

/// Abstract class that combines the ApiAuth interface with the Authentication mixin.
/// This class serves as a base for concrete implementations of the authentication repository.
abstract class ApiAuthRepository with Authentication {}
