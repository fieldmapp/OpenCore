// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_adapater.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileProxyAdapter extends TypeAdapter<FileProxy> {
  @override
  final int typeId = 5;

  @override
  FileProxy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileProxy(
      bucketId: fields[0] as String,
      fileId: fields[1] as String,
      name: fields[2] as String,
      mimeType: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FileProxy obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bucketId)
      ..writeByte(1)
      ..write(obj.fileId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.mimeType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileProxyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
