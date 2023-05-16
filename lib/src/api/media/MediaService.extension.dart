import 'dart:async';
import 'dart:io';
import 'package:core/src/api/Cache.mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:core/core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MediaException implements Exception {
  /// extend if needed, thats just a baseline
  final String? cause;
  MediaException({required this.cause});
}

mixin MediaCacheUtils implements Cache, CacheUtils {
  @override
  Future<bool> entryNeedsSync({required String id}) {
    return needsSync<FileCacheOperation>(id: id, cacheOpKey: cacheOpKey);
  }

  @override
  Future<void> emptyCache(AsyncCallback? onEmptyCache) async {
    if (onEmptyCache != null) {
      await onEmptyCache();
    }
    await clearCache<FileProxy, FileCacheOperation>(cacheOpKey: cacheOpKey);
  }

  @override
  Stream<Map<String, T>> cacheOperationStream<T extends CacheOp>(
      {required Duration interval}) {
    return getCacheOperationStream<T>(
        interval: interval, cacheOpKey: cacheOpKey);
  }
}

class MediaFileCacheManager implements FileCacheManager {
  static const key = 'mediaCache';
  static final CacheManager _instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  @override
  Future<FileInfo?> getFilebyId({required String key}) async {
    final res = await _instance.getFileFromCache(key);
    return res;
  }

  @override
  Future<void> setFile({required String key, required File file}) async {
    await _instance.putFile(key, file.readAsBytesSync());
  }

  @override
  Future<void> removeFile({required String key}) async {
    await _instance.removeFile(key);
  }

  @override
  Future empytCache() async {
    await _instance.emptyCache();
  }
}

abstract class Media with Cache, MediaCacheUtils implements ApiMedia {
  final _mediaKey = "media-key";
  final _fileCacheOpKey = "fileCacheOperations";
  final uuid = const Uuid();

  Future<void> initMedia() async {
    logger.i("INIT MEDIA EXENSIONS");
    await initCache<FileProxy, FileCacheOperation, FileCacheOperationType>(
        proxyAdapter: FileProxyAdapter(),
        cacheOp: FileCacheOperationAdapter(),
        cacheOpType: FileCacheOperationTypeAdapter(),
        boxesToCreate: buckets,
        collectionIdentifier: "mediacollection",
        dirPath: "mediacollection",
        cachekey: _mediaKey,
        cacheOperationKey: _fileCacheOpKey,
        fileCacheManager: MediaFileCacheManager());
  }

  Future<String> get _tempDir async {
    final Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  Future<Uint8List> getFileFromBucket(
      {required String bucket, required String fileId}) async {
    final cacheFile = await getFileFromCache(fileId: fileId);
    if (cacheFile != null) {
      logger.i("Cached File!");
      return cacheFile;
    }
    try {
      logger.i("Fetching new file!");
      final download = await downloadFile(bucket: bucket, fileId: fileId);
      final type = lookupMimeType(download.path);
      final bytes = await download.readAsBytes();
      // update cache only if file doe not need an update
      if (!await needsSync<FileCacheOperation>(
          id: fileId, cacheOpKey: cacheOpKey)) {
        await setFileToCache(key: fileId, file: download);
        await addToCache<FileProxy>(
            boxId: bucket,
            entryId: fileId,
            cacheObj: FileProxy(
                bucketId: bucket,
                fileId: fileId,
                mimeType: type ?? "no-type",
                name: basename(download.path)));
      }
      return bytes;
    } on ConnectionException catch (eConn) {
      logger.i("Connection ${eConn.cause}");
      rethrow;
    } on TimeoutException catch (eTime) {
      logger.e("Timeout ${eTime.message}");
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FileProxy>> getFileListFromBucket({required bucketId}) async {
    final box = await getBox<FileProxy>(id: bucketId);
    try {
      final fileList = await getFileList(bucket: bucketId);
      // update cache
      for (final key in await box.getAllKeys()) {
        // delete all cache entries which do not need to be synced
        // bc these entries only exist on the local device and have no
        // counter part on the server and neither have they been created or updated
        // on the local device in the mean time
        if (!await needsSync<FileCacheOperation>(
            id: key, cacheOpKey: _fileCacheOpKey)) {
          await removeFromCache<FileProxy>(
              boxId: bucketId, entryId: key, box: box);
        }
      }
      for (final element in fileList) {
        // TODO: research/test if this is a preferable cache implementation
        // only update Cache-Entries from the remote if they are not update on the local device
        if (!await needsSync<FileCacheOperation>(
            id: element.fileId, cacheOpKey: _fileCacheOpKey)) {
          await addToCache<FileProxy>(
              boxId: bucketId,
              entryId: element.fileId,
              cacheObj: element,
              box: box);
        }
      }
    } catch (e) {
      logger.e("Error getting FileProxy list $e");
    }

    final allValues = await box.getAllValues();
    final res = allValues.entries
        .map((e) {
          try {
            return e.value;
          } catch (e) {
            logger.e(e);
          }
        })
        .whereType<FileProxy>()
        .toList();
    return res;
  }

  Future<FileProxy> createFileUpload(
      {required String bucketId,
      required String fileName,
      required Uint8List fileBytes}) async {
    final fileId = uuid.v4();

    onError() async {
      final cacheOp = FileCacheOperation(
          entryId: fileId,
          parentId: bucketId,
          fileName: fileName,
          operationType: FileCacheOperationType.upload,
          data: fileBytes);
      await addCacheOp<FileCacheOperation>(
          op: cacheOp, id: fileId, boxId: _fileCacheOpKey);
    }

    final path = await _tempDir;
    final file = File('$path/$fileName');
    await file.writeAsBytes(fileBytes);

    final FileProxy preData = FileProxy(
      bucketId: bucketId,
      fileId: fileId,
      name: fileName,
      mimeType: lookupMimeType(file.path) ?? "no-type",
    );

    try {
      await addToCache<FileProxy>(
          boxId: bucketId, entryId: fileId, cacheObj: preData);
      await setFileToCache(key: fileId, file: file);
      await createFile(bucket: bucketId, fileId: fileId, file: file);
      await removeCacheOp<FileCacheOperation>(
          id: fileId, boxId: _fileCacheOpKey);
    } on ConnectionException catch (eCon) {
      logger.e(eCon.cause);
      if (eCon.type == null) {
        await onError();
      } else {
        rethrow;
      }
    } on TimeoutException catch (eTime) {
      logger.e(eTime);
      await onError();
    } catch (e) {
      logger.e("Other error $e");
    }
    return preData;
  }

  Future<void> removeFile(
      {required String bucketId, required String fileId}) async {
    onError() async {
      await addCacheOp<FileCacheOperation>(
          op: FileCacheOperation(
              entryId: fileId,
              parentId: bucketId,
              fileName:
                  "", // filename doesnt matter bc this file is going to be deleted
              operationType: FileCacheOperationType.delete,
              data: Uint8List(
                  0)), // data empty Byte array, bc we are deleting it anyways
          id: fileId,
          boxId: _fileCacheOpKey);
    }

    try {
      await removeFromCache<FileProxy>(boxId: bucketId, entryId: fileId);
      await deleteFile(bucket: bucketId, fileId: fileId);
      logger.i("Deleted file $fileId from bucket $bucketId");
    } on ConnectionException catch (eApp) {
      logger.e("Connection exception! ${eApp.cause}");
      if (eApp.type == null) {
        // no connection
        await onError();
      }
    } on TimeoutException catch (e) {
      logger.e(e);
      await onError();
    } catch (e) {
      logger.e(e);
      logger.e("Other exception deleting file $fileId from bucket $bucketId");
      rethrow;
    }
  }

  Future<void> syncSingleChange(
      {required FileCacheOperation cacheOperation}) async {
    cacheOperation.isSyncing = true;
    await cacheOperation.save();
    switch (cacheOperation.operationType) {
      case FileCacheOperationType.upload:
        await cacheOperation.delete();
        await createFileUpload(
            bucketId: cacheOperation.parentId,
            fileName: cacheOperation.fileName,
            fileBytes: cacheOperation.data);

        break;
      case FileCacheOperationType.delete:
        await cacheOperation.delete();
        await removeFile(
            bucketId: cacheOperation.parentId, fileId: cacheOperation.entryId);

        break;
      default:
        final msg =
            "Cacheoperation of type ${cacheOperation.operationType} is unkown and can not bbe handeld!";
        logger.e(msg);
        throw MediaException(cause: msg);
    }
  }

  Future<void> syncLocalChanges() async {
    final currentOps =
        await getAllCacheOperations<FileCacheOperation>(boxId: _fileCacheOpKey);
    logger.i("Total changes to sync ${currentOps.length}");
    for (final entry in currentOps.entries) {
      await syncSingleChange(cacheOperation: entry.value);
    }
  }
}
