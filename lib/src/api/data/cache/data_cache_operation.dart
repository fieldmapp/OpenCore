import 'package:core/src/api/Cache.mixin.dart';
import 'package:hive/hive.dart';

part 'data_cache_operation.g.dart';

// run flutter packages pub run build_runner build to generate a new adpater
@HiveType(typeId: 3)
class DataCacheOperation extends HiveObject implements CacheOp {
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
  final String revision;
  @HiveField(4)
  final DataCacheOperationType operationType;
  @HiveField(5)
  final Map<String, dynamic> data;

  DataCacheOperation(
      {required this.entryId,
      required this.parentId,
      required this.operationType,
      required this.revision,
      required this.data});
}

@HiveType(typeId: 4)
enum DataCacheOperationType {
  @HiveField(0)
  update(name: "update"),
  @HiveField(1)
  delete(name: "delete"),
  @HiveField(2)
  create(name: "create");

  const DataCacheOperationType({required this.name});

  final String name;
}
