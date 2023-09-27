import 'dart:async';
import 'package:open_core/core.dart';
import 'package:open_core/src/api/Cache.mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class DataException implements Exception {
  /// extend if needed, thats just a baseline
  final String? cause;
  DataException({required this.cause});
}

mixin DataCacheUtils implements Cache, CacheUtils {
  @override
  Future<bool> entryNeedsSync({required String id}) {
    return needsSync<DataCacheOperation>(id: id, cacheOpKey: cacheOpKey);
  }

  @override
  Future<void> emptyCache(AsyncCallback? onEmptyCache) async {
    if (onEmptyCache != null) {
      await onEmptyCache();
    }
    await clearCache<DataProxy, DataCacheOperation>(cacheOpKey: cacheOpKey);
  }

  @override
  Stream<Map<String, T>> cacheOperationStream<T extends CacheOp>() {
    return getCacheOperationStream<T>(cacheOpKey: cacheOpKey);
  }
}

abstract class Data with Cache, DataCacheUtils implements ApiData {
  final uuid = const Uuid();
  final _dataKey = "data-key";
  final _cacheOpKey = "cacheOperations";

  Future<void> initData() async {
    logger.i("INIT DATA EXENSIONS");
    await initCache<DataProxy, DataCacheOperation, DataCacheOperationType>(
        proxyAdapter: DataProxyAdapter(),
        cacheOp: DataCacheOperationAdapter(),
        cacheOpType: DataCacheOperationTypeAdapter(),
        boxesToCreate: collections,
        collectionIdentifier: getSourceIdentifier(),
        dirPath: "datacollection",
        cachekey: _dataKey,
        cacheOperationKey: _cacheOpKey);
  }

  Future<DataProxy?> getData(
      {required String collectionID,
      required String docID,
      String? revision}) async {
    final box = await getBox<DataProxy>(id: collectionID);

    logger.i("Getting Entry with revision id: $revision");
    final entry = revision != null ? await box.get("$docID:$revision") : null;

    if (entry != null) {
      // Cache hit
      logger.i("Cached revision doc $revision");
      return entry;
    }

    // Cache miss, try to get data from true source
    try {
      logger.i("Fetch new revision");
      final data = await getEntry(collectionId: collectionID, entryId: docID);
      if (!await needsSync<DataCacheOperation>(
          id: docID, cacheOpKey: _cacheOpKey)) {
        await addToCache<DataProxy>(
            boxId: collectionID,
            entryId: "$docID:${data.revision}",
            cacheObj: data,
            box: box);
      }
      return data;
    } on ConnectionException catch (eApp) {
      logger.e(eApp);
      rethrow;
    } on TimeoutException catch (eTime) {
      logger.e(eTime);
      rethrow;
    } catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  Future<List<DataProxy>> listDocuments(String collectionID) async {
    final box = await getBox<DataProxy>(id: collectionID);
    try {
      final docList = await getEntries(collectionId: collectionID);
      // update cache
      for (final val in (await box.getAllValues()).values) {
        // delete all cache entries which do not need to be synced
        // bc these entries only exist on the local device and have no
        // counter part on the server and neither have they been created or updated
        // on the local device in the mean time
        if (!await needsSync<DataCacheOperation>(
            id: val.docId, cacheOpKey: _cacheOpKey)) {
          await removeFromCache<DataProxy>(
              boxId: collectionID,
              entryId: "${val.docId}:${val.revision}",
              box: box);
        }
      }
      for (final element in docList) {
        // TODO: research/test if this is a preferable cache implementation
        // only update Cache-Entries from the remote if they are not update on the local device
        final sync = await needsSync<DataCacheOperation>(
            id: element.docId, cacheOpKey: _cacheOpKey);
        if (!sync) {
          await addToCache<DataProxy>(
              boxId: collectionID,
              entryId: "${element.docId}:${element.revision}",
              cacheObj: element,
              box: box);
        }
      }
    } catch (e) {
      logger.e("Error getting Dataproxy list $e");
    }
    logger.i("RETURNING LIST");
    final allValues = await box.getAllValues();
    logger.i("CACHE VALUES $allValues");
    final resList = allValues.entries
        .map((e) {
          try {
            return e.value;
          } catch (err) {
            logger.e(e.value.content);
            logger.e(err);
          }
        })
        .whereType<DataProxy>()
        .toList();
    return resList;
  }

  /// Method creates a new Document in the given collection
  /// first step is the creation of a local Doc. for offline representation
  /// after that the api request for the creation is send via [_createNewDoc]
  Future<DataProxy?> addNewData(
      Map<String, dynamic> data, String collectionId) async {
    final docId = uuid.v4();
    // create a new/init. revision
    final revision = uuid.v4();
    // set init. revision
    data["revision"] = revision;
    final DataProxy preData = _createLocalDocument(
        collectionId: collectionId,
        databaseId: getSourceIdentifier(),
        docId: docId,
        revision: revision,
        data: data);
    // add to newly created db-entry to the cache
    await addToCache<DataProxy>(
        boxId: collectionId, entryId: "$docId:$revision", cacheObj: preData);
    final doc = await _createNewDoc(
        docId: docId,
        revision: revision,
        collectionId: collectionId,
        data: data);
    return doc;
  }

  Future<DataProxy?> updateData(DataProxy doc) async {
    CollectionBox<DataProxy> box =
        await getBox<DataProxy>(id: doc.collectionId);
    // create a new revision
    final newRevision = uuid.v4();
    // remove old revision
    await removeFromCache<DataProxy>(
        boxId: doc.collectionId, entryId: "${doc.docId}:${doc.revision}");
    // add new revision to cache
    doc.revision = newRevision; // set new revision
    doc.content["revision"] = newRevision;
    await addToCache<DataProxy>(
        boxId: doc.collectionId,
        entryId: "${doc.docId}:$newRevision",
        cacheObj: doc,
        box: box);

    onError({Map<String, dynamic>? error}) async {
      final cacheOp = DataCacheOperation(
          parentId: doc.collectionId,
          entryId: doc.docId,
          revision: newRevision,
          data: doc.content,
          operationType: DataCacheOperationType.update,
          error: error);
      await addCacheOp<DataCacheOperation>(
          op: cacheOp, id: doc.docId, boxId: _cacheOpKey);
    }

    try {
      final res = await updateEntry(
          entryId: doc.docId,
          collectionId: doc.collectionId,
          data: Map.from(doc.content)
            ..removeWhere((k, v) => k.startsWith("\$")));
      await addToCache<DataProxy>(
          boxId: doc.collectionId,
          entryId: "${doc.docId}:$newRevision",
          cacheObj: res,
          box: box);

      /// delete cache op if regular update was successfull
      /// this can happen if the offline changes were not synced autom. when
      /// the device reestablished connection (i.e. if  the user disabled auto syncing)
      await removeCacheOp<DataCacheOperation>(
          id: doc.docId, boxId: _cacheOpKey);
    } on ConnectionException catch (e) {
      if (e.code == 404) {
        // doc not found, (re)create doc instead of update
        await _createNewDoc(
            docId: doc.docId,
            revision: newRevision,
            collectionId: doc.collectionId,
            data: Map.from(doc.content)
              ..removeWhere((k, v) => k.startsWith("\$")));
      }
      if (e.code == null) {
        // failed lookup, offline
        await onError();
      }
      if (e.code == 400) {
        // wrong input or usage
        // todo: call Global snack bar here?
        // - i am undecided about that because, it is another dep. for the dataservice
        //   it is actually not a responsibility to draw ui for this service and this could
        //   also happen if a backgorund sync. is carried out
        // --> maybe rethrow e
        await onError(error: {"cause": e.cause, "type": e.type});
        // rethrow;
      }
    } on TimeoutException catch (eTime) {
      // failed lookup, bad connection
      await onError();
      logger.e(eTime);
    } catch (e) {
      logger.e(e);
    }
    final update = await box.get("${doc.docId}:$newRevision");
    return update;
  }

  Future<dynamic> deleteDoc(
      String docID, String revision, String collectionID) async {
    onError() async {
      final cacheOp = DataCacheOperation(
          parentId: collectionID,
          entryId: docID,
          revision: revision,
          data: {}, // going to be deleted, no need to store the data
          operationType: DataCacheOperationType.delete);
      await addCacheOp<DataCacheOperation>(
          op: cacheOp, id: docID, boxId: _cacheOpKey);
    }

    try {
      await removeFromCache<DataProxy>(
          boxId: collectionID, entryId: "$docID:$revision");
      await removeFromCache<DataCacheOperation>(
          boxId: _cacheOpKey, entryId: docID);
      final res = await deleteEntry(entryId: docID, collectionId: collectionID);
      return res;
    } on ConnectionException catch (e) {
      if (e.type == null) {
        // no connection to service
        await onError();
      }
      // if the doc. could not be found, we dont have to do anything more
    } on TimeoutException catch (eTime) {
      // no/bad connection to service
      logger.i(eTime);
      await onError();
    } catch (e) {
      logger.e(e);
      logger.e("Other exception deleting doc $docID with revision $revision");
      rethrow;
    }
    eventManager.notifyCacheOp();
  }

  Future<void> syncSingleChange(
      {required DataCacheOperation cacheOperation}) async {
    cacheOperation.isSyncing = true;
    await cacheOperation.save();
    switch (cacheOperation.operationType) {
      case DataCacheOperationType.create:
        await cacheOperation.delete();
        await _createNewDoc(
            docId: cacheOperation.entryId,
            revision: cacheOperation.revision,
            collectionId: cacheOperation.parentId,
            data: cacheOperation.data);
        break;
      case DataCacheOperationType.update:
        await cacheOperation.delete();
        final doc = DataProxy(
            databaseId: getSourceIdentifier(),
            collectionId: cacheOperation.parentId,
            docId: cacheOperation.entryId,
            revision: cacheOperation.revision,
            content: cacheOperation.data);
        await updateData(doc);
        break;
      case DataCacheOperationType.delete:
        await cacheOperation.delete();
        await deleteDoc(cacheOperation.entryId, cacheOperation.revision,
            cacheOperation.parentId);
        break;
      default:
        final msg =
            "Cacheoperation of type ${cacheOperation.operationType} is unkown and can not be handeld!";
        logger.e(msg);
        throw DataException(cause: msg);
    }
    eventManager.notifyCacheOp();
  }

  Future<void> syncLocalChanges() async {
    final currentOps =
        await getAllCacheOperations<DataCacheOperation>(boxId: _cacheOpKey);
    logger.i("Total changes to sync ${currentOps.length}");
    for (final entry in currentOps.entries) {
      await syncSingleChange(cacheOperation: entry.value);
    }
  }

  /// create a offline doc, in order to support offline doc. creation
  DataProxy _createLocalDocument(
      {required String collectionId,
      required String databaseId,
      required String docId,
      required String revision,
      required Map<String, dynamic> data}) {
    final time = DateTime.now().toIso8601String();
    final Map<String, dynamic> docMap = {
      "\$collectionId": collectionId,
      "\$databaseId": getSourceIdentifier(),
      "\$id": docId,
      "\$permissions": [],
      "\$updatedAt": time,
      "\$createdAt": time,
      ...data
    };
    return DataProxy(
        collectionId: collectionId,
        content: docMap,
        revision: revision,
        databaseId: databaseId,
        docId: docId);
  }

  /// Api Request to create a new Doc. with the given collection and doc id
  /// if the request fails, the operation is stored as [DataCacheOperation] and
  /// tried again later
  Future<DataProxy?> _createNewDoc(
      {required docId,
      required String revision,
      required String collectionId,
      required Map<String, dynamic> data}) async {
    CollectionBox<DataProxy> box = await getBox<DataProxy>(id: collectionId);

    onError({Map<String, dynamic>? error}) async {
      final cacheOp = DataCacheOperation(
          parentId: collectionId,
          entryId: docId,
          revision: revision,
          data: data,
          operationType: DataCacheOperationType.create,
          error: error);
      await addCacheOp<DataCacheOperation>(
          op: cacheOp, id: docId, boxId: _cacheOpKey);
    }

    try {
      final res = await createEntry(
          entryId: docId,
          revision: revision,
          collectionId: collectionId,
          data: data);
      await addToCache<DataProxy>(
          boxId: collectionId,
          entryId: "$docId:$revision",
          cacheObj: res,
          box: box);

      /// delete cache op if regular doc creation was successfull
      /// this can happen if the offline changes were not synced autom. when
      /// the device reestablished connection (i.e. if  the user disabled auto syncing)
      /// and a doc was created and updated offline.
      await removeCacheOp<DataCacheOperation>(id: docId, boxId: _cacheOpKey);
    } on ConnectionException catch (eApp, e) {
      logger.e(e);
      // creation failed bc there was no internet connection
      // store the operation in the cache box and exec. it if there is a connection again!
      if (eApp.type == null) {
        await onError();
      }
      await onError(error: {"cause": eApp.cause, "type": eApp.type});
    } on TimeoutException catch (e) {
      logger.e(e);
      // creation failed bc there was no or very slow internet connection
      // store the operation in the cache box and exec. it if there is a connection again!
      await onError();
    } catch (e) {
      logger.e("other $e");
    }
    final doc = await box.get("$docId:$revision");
    return doc;
  }
}
