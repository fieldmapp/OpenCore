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
  @HiveField(3)
  String mimeType;

  FileProxy({
    required this.bucketId,
    required this.fileId,
    required this.name,
    required this.mimeType,
  });

  factory FileProxy.fromDoc(Map<String, dynamic> fileMap) {
    return FileProxy(
        bucketId: fileMap["bucketId"].toString(),
        fileId: fileMap["id"].toString(),
        name: fileMap["name"],
        mimeType: fileMap["mimeType"]);
  }

  @override
  String toString() => "bucket $bucketId file  $fileId"; // Just for print()
}
