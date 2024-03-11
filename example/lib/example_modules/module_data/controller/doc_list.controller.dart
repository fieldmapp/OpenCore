import 'package:example/example_modules/module_data/service/doc.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:appwrite/models.dart';

// declare a part file
part 'doc_list.controller.g.dart';
// generate with: dart run build_runner watch

@riverpod
class DocListController extends _$DocListController {
  List<Document> _currentList = [];
  DocService docService = DocService();

  @override
  // note the [Future] return type and the async keyword
  Future<List<Document>> build(String collectionID) async {
    _currentList = await getDocuments();
    return _currentList;
  }

  Future<List<Document>> getDocuments() async {
    state = const AsyncLoading();
    _currentList = await docService.getDocuments(collectionID: collectionID);
    state = AsyncData(_currentList);
    return _currentList;
  }

  Future<Document?> addDoc(
      {required String collectionId,
      required Map<String, dynamic> data}) async {
    state = const AsyncLoading();
    try {
      final newDoc =
          await docService.addDocument(collectionId: collectionId, data: data);
      _currentList.add(newDoc);
      state = AsyncData(_currentList);
      return newDoc;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
    return null;
  }

  Document? getDoc({required String docId}) {
    final res = _currentList.where((element) => element.$id == docId);
    if (res.isNotEmpty) {
      return res.first;
    }
    return null;
  }

  Future removeDoc(
      {required String collectionId,
      required String docId,
      required String revision}) async {
    try {
      await docService.removeDoc(
          collectionId: collectionId, docId: docId, revision: revision);
      _currentList.removeWhere((element) => element.$id == docId);
      state = AsyncData(_currentList);
    } catch (e, stacktrace) {
      state = AsyncError(e, stacktrace);
    }
  }
}
