import 'package:appwrite/models.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

part 'data_adapater.g.dart';

// run flutter packages pub run build_runner build to generate a new adpater
@HiveType(typeId: 2)
class DataProxy extends HiveObject {
  @HiveField(0)
  String databaseId;
  @HiveField(1)
  String collectionId;
  @HiveField(2)
  String docId;
  @HiveField(3)
  String revision;
  @HiveField(4)
  late Map<String, dynamic> content;

  final logger = Logger();

  DataProxy(
      {required this.databaseId,
      required this.collectionId,
      required this.docId,
      required this.revision,
      required this.content});

  factory DataProxy.fromDoc(Document doc) {
    final Logger logger = Logger();
    try {
      final res = DataProxy(
          databaseId: doc.$databaseId,
          collectionId: doc.$collectionId,
          docId: doc.$id,
          revision: doc.data["revision"],
          content: doc.data);
      return res;
    } on Exception catch (e) {
      logger.e("Something went wrong creating DataProxy from Doc $doc");
      logger.e(e);
      rethrow;
    }
  }

  Document getDoc() {
    return Document.fromMap(content);
  }

  @override
  String toString() => "$databaseId $collectionId $docId"; // Just for print()
}
