import 'dart:typed_data';

import 'package:core/src/api/Cache.mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'file_cache_operation.g.dart';

// run flutter packages pub run build_runner build to generate a new adpater
@HiveType(typeId: 21)
class FileCacheOperation extends HiveObject implements CacheOp {
  @override
  @HiveField(0)
  final String entryId;
  @override
  @HiveField(1)
  final String parentId;
  @override
  @HiveField(2)
  bool isSyncing = false;
  @HiveField(3)
  final String fileName;
  @HiveField(4)
  final FileCacheOperationType operationType;
  @HiveField(5)
  final Uint8List data;

  FileCacheOperation(
      {required this.entryId,
      required this.parentId,
      required this.operationType,
      required this.fileName,
      required this.data});
}

@HiveType(typeId: 22)
enum FileCacheOperationType {
  @HiveField(0)
  upload(name: "upload"),
  @HiveField(1)
  delete(name: "delete");

  const FileCacheOperationType({required this.name});

  final String name;
}
