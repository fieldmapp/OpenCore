import 'package:appwrite/models.dart';
import 'package:open_core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

/// APPLICATION LAYER
/// The [DocService] is not concerned about:
/// managing and updating the widget state (that's the job of the controller)
/// data parsing and serialization (that's the job of the repositories)
/// All it does is to implement application-specific logic by accessing the relevant repositories/apiServices as needed.

class DocService {
  static final DocService _docService = DocService._internal();
  final ApiDataRepository _apiService = GetIt.I.get<ApiDataRepository>();
  final logger = Logger();

  factory DocService() {
    return _docService;
  }

  DocService._internal();

  Future<Document> getDocument(
      {required String collectionID,
      required String docID,
      required String? currentRevision,
      bool forceLatest = false}) async {
    DataProxy? res;
    if (forceLatest || currentRevision == null) {
      logger.i("Getting latest changes!");
      try {
        res = await _apiService.getData(
            collectionID: collectionID, docID: docID, revision: null);
      } on Exception catch (e) {
        logger.e(
            "Failed to get latest! Falling back to current revision $currentRevision");
        logger.e(e);
      }
    }
    res = res ??
        await _apiService.getData(
            collectionID: collectionID,
            docID: docID,
            revision: currentRevision);

    if (res != null) {
      return Document.fromMap(res.content);
    }
    throw Exception("Could not get document!");
  }

  Future<List<Document>> getDocuments({required String collectionID}) async {
    final res = await _apiService.listDocuments(collectionID);
    return res.map((e) => Document.fromMap(e.content)).toList();
  }

  Future<Document> addDocument(
      {required String collectionId,
      required Map<String, dynamic> data}) async {
    final newDoc = await _apiService.addNewData(data, collectionId);
    if (newDoc != null) {
      return Document.fromMap(newDoc.content);
    }
    throw Exception("Document not created!");
  }

  Future removeDoc(
      {required String collectionId,
      required String docId,
      required String revision}) async {
    await _apiService.deleteDoc(docId, revision, collectionId);
  }

  Future<DataProxy?> updateDoc({required Document doc}) async {
    return await _apiService
        .updateData(DataProxy.fromCallback(callBack: () => fromDoc(doc)));
  }

  Future<void> resetDataCache() async {
    await _apiService.emptyCache(
      () async {},
    );
  }

  Future<void> resetCollection() async {
    await _apiService.clearSingleBox<DataProxy>(boxId: "1");
  }
}
