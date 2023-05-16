// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_cache_operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileCacheOperationAdapter extends TypeAdapter<FileCacheOperation> {
  @override
  final int typeId = 21;

  @override
  FileCacheOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileCacheOperation(
      entryId: fields[0] as String,
      parentId: fields[1] as String,
      operationType: fields[4] as FileCacheOperationType,
      fileName: fields[3] as String,
      data: fields[5] as Uint8List,
    )..isSyncing = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, FileCacheOperation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.entryId)
      ..writeByte(1)
      ..write(obj.parentId)
      ..writeByte(2)
      ..write(obj.isSyncing)
      ..writeByte(3)
      ..write(obj.fileName)
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
      other is FileCacheOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FileCacheOperationTypeAdapter
    extends TypeAdapter<FileCacheOperationType> {
  @override
  final int typeId = 22;

  @override
  FileCacheOperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FileCacheOperationType.upload;
      case 1:
        return FileCacheOperationType.delete;
      default:
        return FileCacheOperationType.upload;
    }
  }

  @override
  void write(BinaryWriter writer, FileCacheOperationType obj) {
    switch (obj) {
      case FileCacheOperationType.upload:
        writer.writeByte(0);
        break;
      case FileCacheOperationType.delete:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileCacheOperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
