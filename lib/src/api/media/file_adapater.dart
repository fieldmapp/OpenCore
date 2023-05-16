import 'package:hive/hive.dart';

part 'file_adapater.g.dart';

// run flutter packages pub run build_runner build to generate a new adpater
@HiveType(typeId: 5)
class FileProxy extends HiveObject {
  @HiveField(0)
  String bucketId;
  @HiveField(1)
  String fileId;
  @HiveField(2)
  String name;
  // @HiveField(3)
  // Uint8List content;
  @HiveField(3)
  String mimeType;
  // @HiveField(5)
  // bool withData; // indicator if content is empty Byte-Array

  FileProxy({
    required this.bucketId,
    required this.fileId,
    required this.name,
    required this.mimeType,
    // required this.withData,
    // required this.content
  });

  factory FileProxy.fromDoc(Map<String, dynamic> fileMap) {
    return FileProxy(
      bucketId: fileMap["bucketId"].toString(),
      fileId: fileMap["id"].toString(),
      name: fileMap["name"],
      // withData: fileMap["withData"],
      mimeType: fileMap["mimeType"],
      // content: fileMap["content"]
    );
  }

  @override
  String toString() => "bucket $bucketId file  $fileId"; // Just for print()
}
