part of core;

class AppwriteAuthRepository extends ApiAuthRepository {
  final Account account;
  final uuid = const Uuid();

  AppwriteAuthRepository({required this.account});

  @override
  Future createAccount(
      {required String email,
      required String password,
      required String name}) async {
    await account.create(userId: uuid.v4(), email: email, password: password);
  }

  @override
  Future<User> createSession(
      {required String email, required String password}) async {
    final session =
        await account.createEmailSession(email: email, password: password);
    final expire = DateTime.parse(session.expire);
    final user = await account.get();
    final cacheUser =
        User(user.name, user.email, expire.millisecondsSinceEpoch);

    return cacheUser;
  }

  @override
  Future deleteSession({String sessionId = "current"}) async {
    await account.deleteSession(sessionId: sessionId);
  }

  @override
  Future updateSession({required String sessionId}) async {
    await account.updateSession(sessionId: sessionId);
  }

  @override
  Future<void> init() async {
    logger.i("Init Appwrite Auth!");
    await Hive.initFlutter();
    await initAuth();
  }

  @override
  Logger get logger => Logger();
}
