part of core;

abstract class ApiAuth {
  final logger = Logger();

  Future<void> init();

  @protected
  Future deleteSession({required String sessionId});

  @protected
  Future updateSession({required String sessionId});

  @protected
  Future<User> createSession({required String email, required String password});

  @protected
  Future createAccount(
      {required String email, required String password, required String name});
}

abstract class ApiAuthRepository with Authentication {}
