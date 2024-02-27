import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheOp extends HiveObject {
  final String entryId;
  final String parentId;
  bool isSyncing;

  CacheOp(this.entryId, this.parentId, this.isSyncing);
}

class CacheEventManager<T extends CacheOp> {
  final StreamController<void> _cacheOpEventController =
      StreamController<void>.broadcast();

  // External methods to trigger cache events
  void notifyCacheOp() {
    _cacheOpEventController.add(null);
  }

  Stream<void> get cacheOpEventStream => _cacheOpEventController.stream;
}

abstract class CacheUtils {
  Future<void> emptyCache(AsyncCallback? onEmptyCache);
  Future<bool> entryNeedsSync({required String id});
  Stream<Map<String, T>> cacheOperationStream<T extends CacheOp>();
}

abstract class FileCacheManager {
  Future<FileInfo?> getFilebyId({required String key});

  Future<void> setFile({required String key, required File file});

  Future<void> removeFile({required String key});

  Future empytCache();
}

/// Central Cache Mixin used by [Data] and [Media] Services to handle common and
/// shared CacheOperations like adding, removing and updating the local cache.
/// Cache is implemented using the Hive Package. Cache Boxes are Organized in
/// Boxcollections [collection], where each Box has a parent identifier and a
/// Box-Identifier i.e.:
/// Data-Cache: Parent-Id -> DatabaseId, Box-Id -> Collection/Table-Id
/// all Box-Ids are stored in a Set of Strings called [boxes], all boxes are initialized
/// in [_initCollection].
/// The Cache Mixin also stores the key [cacheOpKey] for the relevant [CacheOp] (Cacheoperations)
/// of this mixin. The Cacheopertions are also cached/stored as Box in the Boxcollection,
/// the box is created once the collections got initialized in [_initCollection].
/// These cacheoperations are used to sync the offline changes once the device restored
/// a network connection.
/// All cached data is stored with AES encryption.
mixin Cache {
  late BoxCollection collection;
  late final Set<String> boxes;
  late final String cacheOpKey;
  final logger = Logger();
  FileCacheManager? _fileCacheManager;
  final _secureStorage = const FlutterSecureStorage();
  final _aOptions = const AndroidOptions(encryptedSharedPreferences: true);
  final _iOptions =
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  final CacheEventManager<CacheOp> eventManager = CacheEventManager<CacheOp>();

  /// Initializes the Cache Mixin and registers all provided [TypeAdapter]s.
  ///
  /// A [proxyAdapter] is needed to define the type of the [HiveObject]s which are
  /// supposed to be cached i.e. [FileProxy]. It is also needed to define a [cacheOp]
  /// and a [cacheOpType] Adapter to ensure the Type of Cacheoperations [DataCacheOperation]
  /// and the Enum of CacheoperationsTypes [DataCacheOperationType] for the Cache-Mixin.
  /// These are needed to sync local changes with the remote counterpart.
  ///
  /// The Parameter [boxesToCreate] is used to initialize or reopen all needed Cache
  /// Boxes for this Mixin, i.e. for the Database-Cache used in [Data] this Parameter
  /// contains all Database-Collections which are supposed to be cached.
  ///
  /// The Parameters [collectionIdentifier], [dirPath], [cachekey] and [cacheOperationKey]
  /// are needed to create and persist the Boxcollection used by this Cache Mixin.
  Future<void> initCache<T, R extends CacheOp, K>(
      {required TypeAdapter<T> proxyAdapter,
      required TypeAdapter<R> cacheOp,
      required TypeAdapter<K> cacheOpType,
      required Set<String> boxesToCreate,
      required String collectionIdentifier,
      required String dirPath,
      required String cachekey,
      required String cacheOperationKey,
      FileCacheManager? fileCacheManager}) async {
    if (!Hive.isAdapterRegistered(proxyAdapter.typeId)) {
      Hive.registerAdapter(proxyAdapter);
    }
    if (!Hive.isAdapterRegistered(cacheOp.typeId)) {
      Hive.registerAdapter(cacheOp);
    }
    if (!Hive.isAdapterRegistered(cacheOpType.typeId)) {
      Hive.registerAdapter(cacheOpType);
    }

    cacheOpKey = cacheOperationKey;
    if (fileCacheManager != null) {
      _fileCacheManager = fileCacheManager;
    }
    final dir = await _initDataDir(path: dirPath);
    collection = await _initCollection(
        dataCollectionDir: dir,
        boxesToCreate: boxesToCreate,
        collectionIdentifier: collectionIdentifier,
        cachekey: cachekey,
        cacheOpKey: cacheOpKey);
  }

  Future<BoxCollection> _initCollection(
      {required Directory dataCollectionDir,
      required Set<String> boxesToCreate,
      required String collectionIdentifier,
      required String cachekey,
      required String cacheOpKey}) async {
    // if key not exists return null
    final encryptionKey = await _secureStorage.read(
        key: cachekey, aOptions: _aOptions, iOptions: _iOptions);
    if (encryptionKey == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
          key: cachekey,
          value: base64UrlEncode(key),
          aOptions: _aOptions,
          iOptions: _iOptions);
    }
    final key = await _secureStorage.read(
        key: cachekey, aOptions: _aOptions, iOptions: _iOptions);
    boxes = {
      ...boxesToCreate,
      ...{cacheOpKey}
    };
    return await BoxCollection.open(
      collectionIdentifier, // Name of your database
      boxes, // Names of your boxes
      path: dataCollectionDir
          .path, // Path where to store your boxes (Only used in Flutter / Dart IO)
      key: HiveAesCipher(base64Url.decode(
          key!)), // Key to encrypt your boxes (Only used in Flutter / Dart IO)
    );
  }

  Future<Directory> _initDataDir({required String path}) async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    Directory dataCollectionDir =
        await Directory("${appDocDirectory.path}/$path")
            .create(recursive: true);
    return dataCollectionDir;
  }

  Future<void> addBoxToCollection(
      {required String newBoxName,
      required String dataCollectionDir,
      required String collectionIdentifier,
      required String cachekey}) async {
    final dataPath = await _initDataDir(path: dataCollectionDir);
    final encryptionKey = await _secureStorage.read(
        key: cachekey, aOptions: _aOptions, iOptions: _iOptions);
    if (encryptionKey == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
          key: cachekey,
          value: base64UrlEncode(key),
          aOptions: _aOptions,
          iOptions: _iOptions);
    }
    final key = await _secureStorage.read(
        key: cachekey, aOptions: _aOptions, iOptions: _iOptions);
    collection.close();
    collection = await BoxCollection.open(
      collection.name, // Name of your database
      {...collection.boxNames, newBoxName}, // Names of your boxes
      path: dataPath
          .path, // Path where to store your boxes (Only used in Flutter / Dart IO)
      key: HiveAesCipher(base64Url.decode(
          key!)), // Key to encrypt your boxes (Only used in Flutter / Dart IO)
    );
  }

  /// Returns the requested [CollectionBox] based on the given [id]. ALWAYS
  /// pass a generic type [T] otherwise Hive can not retrieve the correct Box.
  @protected
  Future<CollectionBox<T>> getBox<T>({required String id}) {
    return collection.openBox<T>(id);
  }

  /// Adds a entry of type [T] to the corresponding box with the given [boxId].
  /// If you already opened the corresponding box [box] you can provide the box
  /// as optional parameter.
  /// ALWAYS pass a generic type [T] otherwise Hive can not retrieve the correct Box.
  ///
  /// ```dart
  /// await addToCache<FileProxy>(boxId: "box1", entryId:"first", FileProxy());
  /// ```
  @protected
  Future<void> addToCache<T>(
      {required String boxId,
      required String entryId,
      required T cacheObj,
      CollectionBox<T>? box}) async {
    try {
      box ??= await getBox<T>(id: boxId);
      await box.put(entryId, cacheObj);
    } catch (e) {
      logger.e(e);
      logger.e("Could not add $cacheObj to Box $boxId");
    }
  }

  /// Removes a entry of type [T] from cache by providing the [boxId] and [entryId]
  /// If you already opened the corresponding box [box] you can provide the box
  /// as optional parameter.
  /// ALWAYS pass a generic type [T] otherwise Hive can not retrieve the correct Box.
  @protected
  Future<void> removeFromCache<T extends HiveObject>(
      {required String boxId,
      required String entryId,
      CollectionBox<T>? box}) async {
    try {
      box ??= await getBox<T>(id: boxId);
      final res = await box.get(entryId);
      if (res != null) {
        await res.delete();
        return;
      }

      throw Exception(
          "Entry from box $boxId with id $entryId can not be deleted because it was not found!");

      // await box.delete(entryId);
    } on Exception catch (e) {
      logger.e(e);
      logger.e("Could not remove $entryId from Box $boxId");
    }
  }

  /// Adds a CacheOperation to the Cache-box, pretty much the same as [addToCache]
  /// but the generic type has to be of type [CacheOp].
  @protected
  Future<void> addCacheOp<T extends CacheOp>(
      {required T op, required String id, required String boxId}) async {
    try {
      await addToCache<T>(boxId: boxId, entryId: id, cacheObj: op);
      eventManager.notifyCacheOp();
    } on Exception catch (e) {
      logger.e(e);
      rethrow;
    }
  }

  /// Remove a [CacheOp] from the Cache Box if a CacheOp acutally exists for this entry
  @protected
  Future<void> removeCacheOp<T extends CacheOp>(
      {required id, required boxId}) async {
    logger.d("Remove CacheOP $id");
    if (await needsSync<T>(id: id, cacheOpKey: boxId)) {
      await removeFromCache<T>(boxId: boxId, entryId: id);
      eventManager.notifyCacheOp();
    }
  }

  /// Returns all entries of a Box as Map, the generic type has to be of type [CacheOp].
  @protected
  Future<Map<String, T>> getAllCacheOperations<T extends CacheOp>(
      {required String boxId}) async {
    final cacheOpBox = await collection.openBox<T>(boxId);
    return await cacheOpBox.getAllValues();
  }

  /// Clears the complete Cache for this cache mixin.
  ///
  /// Wrapper function for [flushCollection] to clear the cache of normal entries
  /// like [FileProxy] or [DataProxy] as well as the corresponding Cacheoperations,
  /// like [FileCacheOperation] or [DataCacheOperation].
  ///
  /// ```dart
  /// await clearCache<FileProxy, FileCacheOperation>(cacheOpKey: cacheOpKey);
  /// ```
  @protected
  Future<void> clearCache<T, R extends CacheOp>(
      {required String cacheOpKey}) async {
    await Future.wait(
        [_flushCollection<T, R>(cacheOpKey: cacheOpKey), _emptyFileCache()]);
  }

  Future<void> clearSingleBox<T>({required String boxId}) async {
    try {
      CollectionBox box = await collection.openBox<T>(boxId);
      await box.clear();
      await box.flush();
    } catch (e) {
      throw Exception("Something went wrong clearing cached box $cacheOpKey");
    }
  }

  Future<void> _flushCollection<T, R extends CacheOp>(
      {required String cacheOpKey}) async {
    for (final boxId in boxes) {
      CollectionBox box;
      if (boxId == cacheOpKey) {
        box = await collection.openBox<R>(boxId);
      } else {
        box = await collection.openBox<T>(boxId);
      }
      await box.clear();
      await box.flush();
    }
    eventManager.notifyCacheOp();
    logger.i("CACHE COLLECTION FLUSHED!");
  }

  /// Checks if the prodived [id] has open CacheOperations and thus needs synchronisation.
  ///
  /// ALWAYS pass a generic type [T] otherwise Hive can not retrieve the correct Box.
  @protected
  Future<bool> needsSync<T extends CacheOp>(
      {required String id, required String cacheOpKey}) async {
    final cacheOpBox = await getBox<T>(id: cacheOpKey);
    final res = await cacheOpBox.get(id) != null;
    logger.i("$id needs sync $res");
    return res;
  }

  /// Returns a stream of open CacheOperations, for this CacheMixin.
  ///
  @protected
  Stream<Map<String, T>> getCacheOperationStream<T extends CacheOp>(
      {required String cacheOpKey}) {
    late StreamController<Map<String, T>> controller;
    Map<String, T> cacheMap = {};

    StreamSubscription? eventSub;
    controller = StreamController<Map<String, T>>(onListen: () async {
      // Attach event listener
      cacheMap = await getAllCacheOperations<T>(boxId: cacheOpKey);
      controller.add(cacheMap);
      eventSub = eventManager.cacheOpEventStream.listen((_) async {
        cacheMap = await getAllCacheOperations<T>(boxId: cacheOpKey);
        controller.add(cacheMap);
      });
    }, onCancel: () {
      eventSub!.cancel();
      // Handle cleanup if needed
    });
    return controller.stream;
  }

  @protected
  Future<Uint8List?> getFileFromCache({required String fileId}) async {
    if (_fileCacheManager != null) {
      final res = await _fileCacheManager!.getFilebyId(key: fileId);
      if (res != null) {
        return res.file.readAsBytesSync();
      }
      return null;
    }
    logger.e("No FileCacheManager set for this CacheMixin!");
    return null;
  }

  @protected
  Future<void> setFileToCache({required String key, required File file}) async {
    if (_fileCacheManager != null) {
      await _fileCacheManager!.setFile(key: key, file: file);
      return;
    }
    logger.e("No FileCacheManager set for this CacheMixin!");
  }

  @protected
  Future<void> removeFileFromCache({required String key}) async {
    if (_fileCacheManager != null) {
      await _fileCacheManager!.removeFile(key: key);
      logger.i("File with key $key removed from cache!");
      return;
    }
    logger.e("No FileCacheManager set for this CacheMixin!");
  }

  @protected
  Future<void> _emptyFileCache() async {
    if (_fileCacheManager != null) {
      await _fileCacheManager!.empytCache();
      return;
    }
    logger.e("No FileCacheManager set for this CacheMixin!");
  }
}
