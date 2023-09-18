import 'dart:async';

import 'package:appwrite/models.dart';
import 'package:example/example_modules/module_data/controller/doc_list.controller.dart';
import 'package:example/example_modules/module_data/service/doc.service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// declare a part file
part 'doc.controller.g.dart';

// generate with: dart run build_runner watch

@riverpod
class DocController extends _$DocController {
  late Document _currentDoc;
  final DocService _docService = DocService();
  final Logger logger = Logger();

  @override
  // note the [Future] return type and the async keyword
  Future<Document> build(
      String collectionID, String docId, String? revision) async {
    try {
      _currentDoc = (await getDoc(
          collectionID: collectionID, docID: docId, revision: revision))!;
    } catch (e) {
      _currentDoc = Document.fromMap({});
    }

    return _currentDoc;
  }

  Future<Document?> getDoc(
      {required String collectionID,
      required String docID,
      String? revision}) async {
    state = const AsyncLoading();
    try {
      _currentDoc = await _docService.getDocument(
          collectionID: collectionID, docID: docID, currentRevision: revision);
      state = AsyncData(_currentDoc);
      return _currentDoc;
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
    return null;
  }

  Future removeDoc(
      {required String collectionId,
      required String docId,
      required String revisionId}) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(DocListControllerProvider(collectionID).notifier)
          .removeDoc(
              collectionId: collectionId, docId: docId, revision: revisionId);
    } catch (e, stacktrace) {
      state = AsyncError(e, stacktrace);
    }
  }

  Future getNewestVersion() async {
    state = const AsyncLoading();
    try {
      logger.i("NEWEST VERSION ${_currentDoc.data["revision"]}, force latest!");
      _currentDoc = await _docService.getDocument(
          collectionID: collectionID,
          docID: docId,
          currentRevision: _currentDoc.data["revision"],
          forceLatest: true);
      state = AsyncData(_currentDoc);
    } catch (e, stacktrace) {
      state = AsyncError(e, stacktrace);
    }
  }

  Future<void> updateDoc({required Map<String, dynamic> data}) async {
    state = const AsyncLoading();
    try {
      for (final entry in data.entries) {
        _currentDoc.data[entry.key] = entry.value;
      }
      final updated = await _docService.updateDoc(doc: _currentDoc);
      await ref
          .read(DocListControllerProvider(collectionID).notifier)
          .getDocuments();
      if (updated != null) {
        _currentDoc = Document.fromMap(updated.content);
      }
      state = AsyncData(_currentDoc);
    } catch (e, stackstrace) {
      state = AsyncError(e, stackstrace);
    }
  }
}
