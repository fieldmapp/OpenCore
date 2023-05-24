import 'package:open_core/core.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

class AppwriteDataRepository extends ApiDataRepository {
  final Databases database;
  final String databaseId;
  // custom timelimit,  determines how long a future should run before it is timouted
  final timelimit = const Duration(seconds: 1, milliseconds: 500);

  AppwriteDataRepository({
    required this.database,
    required this.collections,
    required this.databaseId,
  });

  @override
  getSourceIdentifier() {
    return databaseId;
  }

  // Data
  @override
  Future<DataProxy> getEntry(
      {required String collectionId, required String entryId}) async {
    try {
      final doc = await database
          .getDocument(
              databaseId: databaseId,
              collectionId: collectionId,
              documentId: entryId)
          .timeout(timelimit);
      return DataProxy.fromDoc(doc);
    } on AppwriteException catch (eApp) {
      throw ConnectionException(
          cause: eApp.message, code: eApp.code, type: eApp.type);
    } catch (e) {
      logger.e(
          "Something went wrong getting entry with $entryId from collection $collectionId via Appwrite");
      logger.e(e);
      rethrow;
    }
  }

  @override
  Future<List<DataProxy>> getEntries(
      {required String collectionId, List<String>? queries}) async {
    final docs = await database
        .listDocuments(
            databaseId: databaseId,
            collectionId: collectionId,
            queries: queries)
        .timeout(timelimit);

    final res = docs.documents.map((e) => DataProxy.fromDoc(e)).toList();
    return res;
  }

  @override
  Future<DataProxy> createEntry(
      {required String entryId,
      required String revision,
      required String collectionId,
      required Map<String, dynamic> data}) async {
    try {
      final res = await database
          .createDocument(
              databaseId: databaseId,
              collectionId: collectionId,
              documentId: entryId,
              data: data)
          .timeout(timelimit);
      return DataProxy.fromDoc(res);
    } on AppwriteException catch (eApp) {
      throw ConnectionException(
          cause: eApp.message, code: eApp.code, type: eApp.type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DataProxy> updateEntry(
      {required String entryId,
      required String collectionId,
      required Map<String, dynamic> data}) async {
    try {
      final res = await database
          .updateDocument(
              databaseId: databaseId,
              collectionId: collectionId,
              documentId: entryId,
              data: data)
          .timeout(timelimit);

      return DataProxy(
          databaseId: databaseId,
          collectionId: collectionId,
          docId: entryId,
          revision: res.data["revision"],
          content: res.data);
    } on AppwriteException catch (eApp) {
      throw ConnectionException(
          cause: eApp.message, code: eApp.code, type: eApp.type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future deleteEntry(
      {required String entryId, required String collectionId}) async {
    try {
      final res = await database
          .deleteDocument(
              databaseId: databaseId,
              collectionId: collectionId,
              documentId: entryId)
          .timeout(timelimit);
      return res;
    } on AppwriteException catch (eApp) {
      throw ConnectionException(
          cause: eApp.message, code: eApp.code, type: eApp.type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Set<String> collections;

  @override
  Future<void> init() async {
    logger.i("Init Appwrite Data");
    await Hive.initFlutter();
    await initData();
  }

  @override
  Logger get logger => Logger();
}
