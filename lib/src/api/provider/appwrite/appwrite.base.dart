import 'package:appwrite/appwrite.dart';

class AppwriteBase {
  late final Client _client;
  late final Account account;
  late final Databases database;
  late final Storage storage;

  static final AppwriteBase _appwriteBase = AppwriteBase._internal();

  AppwriteBase._internal();

  factory AppwriteBase(
      {required String endpoint,
      required String projectId,
      required bool selfSigned}) {
    _appwriteBase._client = Client(endPoint: endpoint)
        .setProject(projectId)
        .setSelfSigned(status: selfSigned);
    _appwriteBase.account = Account(_appwriteBase._client);
    _appwriteBase.database = Databases(_appwriteBase._client);
    _appwriteBase.storage = Storage(_appwriteBase._client);
    return _appwriteBase;
  }
}
