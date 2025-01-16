import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

part 'data_adapater.g.dart';

// run flutter packages pub run build_runner build to generate a new adpater

/// A proxy class for managing persistent data with Hive storage.
///
/// This class extends [HiveObject] and provides a structure for storing
/// and managing document data with associated metadata. It includes:
/// * Database and collection identification
/// * Document versioning
/// * Content storage
/// * Timestamp tracking
///
/// The class is annotated with [HiveType] for persistent storage
/// and includes fields marked with [HiveField] for serialization.
@HiveType(typeId: 2)
class DataProxy extends HiveObject {
  /// The identifier of the database containing this data.
  ///
  /// This field uniquely identifies the database instance
  /// where the document is stored.
  @HiveField(0)
  String databaseId;

  /// The identifier of the collection containing this data.
  ///
  /// This field specifies which collection within the database
  /// the document belongs to.
  @HiveField(1)
  String collectionId;

  /// The unique identifier of the document.
  ///
  /// This field contains the specific identifier for this
  /// document within its collection.
  @HiveField(2)
  String docId;

  /// The revision identifier of the document.
  ///
  /// This field tracks the version or revision of the document,
  /// useful for managing updates and conflicts.
  @HiveField(3)
  String revision;

  /// The actual content of the document.
  ///
  /// A map containing the document's data. This field is marked
  /// as 'late' since it might be loaded after initial object creation.
  @HiveField(4)
  late Map<String, dynamic> content;

  /// ISO formatted timestamp of the last update.
  ///
  /// Records when the document was last modified, stored
  /// in ISO 8601 format.
  @HiveField(5)
  String lastUpdatedISO;

  /// Logger instance for tracking operations and debugging.
  final logger = Logger();

  /// Creates a new DataProxy instance.
  ///
  /// Parameters:
  /// * [databaseId] - The identifier of the database
  /// * [collectionId] - The identifier of the collection
  /// * [docId] - The document's unique identifier
  /// * [revision] - The document's revision identifier
  /// * [lastUpdatedISO] - ISO formatted timestamp of last update
  /// * [content] - The document's content as a map
  DataProxy(
      {required this.databaseId,
      required this.collectionId,
      required this.docId,
      required this.revision,
      required this.lastUpdatedISO,
      required this.content});

  /// Factory constructor that creates a DataProxy from a callback function.
  ///
  /// This constructor provides error handling around the creation process.
  ///
  /// Parameters:
  /// * [callBack] - A function that returns a DataProxy instance
  ///
  /// Returns:
  /// * The DataProxy instance created by the callback
  ///
  /// Throws:
  /// * Rethrows any exceptions that occur during creation
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

  /// Provides a string representation of the DataProxy.
  ///
  /// Returns a space-separated string containing:
  /// * Database ID
  /// * Collection ID
  /// * Document ID
  ///
  /// This is primarily used for debugging and logging purposes.
  @override
  String toString() => "$databaseId $collectionId $docId";
}
