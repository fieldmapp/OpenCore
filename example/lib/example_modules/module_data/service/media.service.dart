import 'dart:typed_data';
import 'package:open_core/core.dart';
import 'package:get_it/get_it.dart';

/// TODO: add toast service to display errors, like deletion
/// got denied because of missing permissions

class MediaService {
  static final MediaService _docService = MediaService._internal();
  final ApiMediaRepository _apiService = GetIt.I.get<ApiMediaRepository>();

  factory MediaService() {
    return _docService;
  }

  MediaService._internal();

  Future<List<FileProxy>> listFilesOfBucket({required String bucket}) async {
    final list = await _apiService.getFileListFromBucket(bucketId: bucket);
    return list;
  }

  Future<Uint8List> getFile(
      {required String bucketId, required String fileId}) async {
    return await _apiService.getFileFromBucket(
        bucket: bucketId, fileId: fileId);
  }

  Future<FileProxy> createUpload(
      {required String bucketId,
      required String fileName,
      required Uint8List fileBytes}) async {
    return await _apiService.createFileUpload(
        fileName: fileName, bucketId: bucketId, fileBytes: fileBytes);
  }

  Future<void> removeFile(
      {required String bucketId, required String fileId}) async {
    return await _apiService.removeFile(bucketId: bucketId, fileId: fileId);
  }

  Future<void> resetMediaCache() async {
    await _apiService.emptyCache(
      () async {},
    );
  }

  Future<bool> needsSync({required fileId}) {
    return _apiService.entryNeedsSync(id: fileId);
  }
}
