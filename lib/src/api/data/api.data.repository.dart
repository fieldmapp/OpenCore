part of core;

/// Abstract class providing a foundation for API data management.
///
/// This class serves as a base for implementing API data operations, including:
/// * Collection management
/// * CRUD operations for data entries
/// * Logging capabilities
///
/// All methods marked with [@protected] are intended for internal use
/// by implementing classes.
abstract class ApiData {
  /// Set of collection identifiers managed by this API data instance.
  ///
  /// This property is initialized late and should contain all valid
  /// collection identifiers that can be used with this API.
  late final Set<String> collections;

  /// Logger instance for tracking operations and debugging.
  ///
  /// Provides logging capabilities for tracking API operations,
  /// debugging issues, and monitoring data flow.
  final logger = Logger();

  /// Initializes the API data instance.
  ///
  /// This method should be called before any other operations.
  /// Implementing classes should use this to:
  /// * Set up initial collections
  /// * Initialize connections
  /// * Perform any necessary setup operations
  Future<void> init();

  /// Returns the unique identifier for this data source.
  ///
  /// [@protected] This method is intended for internal use only.
  /// Implementing classes should provide a unique identifier that
  /// distinguishes this data source from others.
  @protected
  getSourceIdentifier();

  /// Retrieves a single entry from a collection.
  ///
  /// [@protected] This method is intended for internal use only.
  ///
  /// Parameters:
  /// * [collectionId] - The identifier of the collection containing the entry
  /// * [entryId] - The unique identifier of the entry to retrieve
  ///
  /// Returns a [DataProxy] representing the retrieved entry.
  @protected
  Future<DataProxy> getEntry(
      {required String collectionId, required String entryId});

  /// Retrieves multiple entries from a collection.
  ///
  /// [@protected] This method is intended for internal use only.
  ///
  /// Parameters:
  /// * [collectionId] - The identifier of the collection to query
  /// * [queries] - Optional list of query strings to filter the entries
  ///
  /// Returns a list of [DataProxy] objects representing the matching entries.
  @protected
  Future<List<DataProxy>> getEntries(
      {required String collectionId, List<String>? queries});

  /// Creates a new entry in a collection.
  ///
  /// [@protected] This method is intended for internal use only.
  ///
  /// Parameters:
  /// * [entryId] - The unique identifier for the new entry
  /// * [revision] - The revision identifier for the entry
  /// * [collectionId] - The identifier of the collection to add the entry to
  /// * [data] - The data to store in the entry
  ///
  /// Returns a [DataProxy] representing the created entry.
  @protected
  Future<DataProxy> createEntry(
      {required String entryId,
      required String revision,
      required String collectionId,
      required Map<String, dynamic> data});

  /// Updates an existing entry in a collection.
  ///
  /// [@protected] This method is intended for internal use only.
  ///
  /// Parameters:
  /// * [entryId] - The unique identifier of the entry to update
  /// * [collectionId] - The identifier of the collection containing the entry
  /// * [data] - The updated data to store
  /// * [offlineOnly] - If true, the update is only stored locally
  ///
  /// Returns a [DataProxy] representing the updated entry.
  @protected
  Future<DataProxy> updateEntry({
    required String entryId,
    required String collectionId,
    required Map<String, dynamic> data,
    bool offlineOnly = false,
  });

  /// Deletes an entry from a collection.
  ///
  /// [@protected] This method is intended for internal use only.
  ///
  /// Parameters:
  /// * [entryId] - The unique identifier of the entry to delete
  /// * [collectionId] - The identifier of the collection containing the entry
  ///
  /// Returns a dynamic value representing the result of the deletion operation.
  @protected
  Future<dynamic> deleteEntry(
      {required String entryId, required String collectionId});
}

/// Abstract class extending [Data] for repository-specific API operations.
///
/// This class serves as a bridge between the base [Data] class and
/// specific API implementations, allowing for customization of data
/// operations while maintaining the core data management structure.
abstract class ApiDataRepository extends Data {}
