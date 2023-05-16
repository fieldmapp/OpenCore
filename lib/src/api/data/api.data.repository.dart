import 'package:open_core/core.dart';
import 'package:open_core/src/api/data/data_service.extension.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

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
  Future<DataProxy> updateEntry(
      {required String entryId,
      required String collectionId,
      required Map<String, dynamic> data});

  @protected
  Future<dynamic> deleteEntry(
      {required String entryId, required String collectionId});
}

abstract class ApiDataRepository extends Data {}
