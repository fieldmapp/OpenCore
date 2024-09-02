part of core;

abstract class ApiData {
  late final Set<String> collections;
  final logger = Logger();

  Future<void> init();

  @protected
  getSourceIdentifier();

  @protected
  Future<DataProxy> getEntry(
      {required String collectionId, required String entryId});

  @protected
  Future<List<DataProxy>> getEntries(
      {required String collectionId, List<String>? queries});

  @protected
  Future<DataProxy> createEntry(
      {required String entryId,
      required String revision,
      required String collectionId,
      required Map<String, dynamic> data});

  @protected
  Future<DataProxy> updateEntry({
    required String entryId,
    required String collectionId,
    required Map<String, dynamic> data,
    bool offlineOnly = false,
  });

  @protected
  Future<dynamic> deleteEntry(
      {required String entryId, required String collectionId});
}

abstract class ApiDataRepository extends Data {}
