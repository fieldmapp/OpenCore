// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_adapater.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataProxyAdapter extends TypeAdapter<DataProxy> {
  @override
  final int typeId = 2;

  @override
  DataProxy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataProxy(
      databaseId: fields[0] as String,
      collectionId: fields[1] as String,
      docId: fields[2] as String,
      revision: fields[3] as String,
      content: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DataProxy obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.databaseId)
      ..writeByte(1)
      ..write(obj.collectionId)
      ..writeByte(2)
      ..write(obj.docId)
      ..writeByte(3)
      ..write(obj.revision)
      ..writeByte(4)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataProxyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
