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
  @HiveField(5)
  String lastUpdatedISO;

  final logger = Logger();

  DataProxy(
      {required this.databaseId,
      required this.collectionId,
      required this.docId,
      required this.revision,
      required this.lastUpdatedISO,
      required this.content});

  factory DataProxy.fromCallback({required DataProxy Function() callBack}) {
    final Logger logger = Logger();
    try {
      final res = callBack();
      return res;
    } on Exception catch (e) {
      logger.e("Something went wrong creating DataProxy from callBack");
      logger.e(e);
      rethrow;
    }
  }

  @override
  String toString() => "$databaseId $collectionId $docId"; // Just for print()
}
