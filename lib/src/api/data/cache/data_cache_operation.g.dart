// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_cache_operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataCacheOperationAdapter extends TypeAdapter<DataCacheOperation> {
  @override
  final int typeId = 3;

  @override
  DataCacheOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataCacheOperation(
      entryId: fields[0] as String,
      parentId: fields[1] as String,
      operationType: fields[4] as DataCacheOperationType,
      revision: fields[3] as String,
      data: (fields[5] as Map).cast<String, dynamic>(),
    )..isSyncing = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, DataCacheOperation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.entryId)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.isSyncing)
      ..writeByte(3)
      ..write(obj.revision)
      ..writeByte(4)
      ..write(obj.operationType)
      ..writeByte(5)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataCacheOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataCacheOperationTypeAdapter
    extends TypeAdapter<DataCacheOperationType> {
  @override
  final int typeId = 4;

  @override
  DataCacheOperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DataCacheOperationType.update;
      case 1:
        return DataCacheOperationType.delete;
      case 2:
        return DataCacheOperationType.create;
      default:
        return DataCacheOperationType.update;
    }
  }

  @override
  void write(BinaryWriter writer, DataCacheOperationType obj) {
    switch (obj) {
      case DataCacheOperationType.update:
        writer.writeByte(0);
        break;
      case DataCacheOperationType.delete:
        writer.writeByte(1);
        break;
      case DataCacheOperationType.create:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataCacheOperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
