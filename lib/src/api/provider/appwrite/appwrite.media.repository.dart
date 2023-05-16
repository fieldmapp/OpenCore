import 'dart:io';
import 'package:OpenCore/core.dart';
import 'package:appwrite/appwrite.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AppwriteMediaRepository extends ApiMediaRepository {
  final Storage storage;
  // custom timelimit,  determines how long a future should run before it is timeouted
  final _downLoadTimelimit = const Duration(seconds: 3, milliseconds: 500);
  final _uploadTimelimit = const Duration(seconds: 6, milliseconds: 500);
  AppwriteMediaRepository({required this.storage, required this.buckets});

  Future<String> get _tempDir async {
    final Directory tempDir = await getTemporaryDirectory();
    return tempDir.path;
  }

  @override
  Future createFile(
      {required String bucket,
      required String fileId,
      required File file}) async {
    try {
      final res = await storage
          .createFile(
              bucketId: bucket,
              fileId: fileId,
              file: InputFile(path: file.path))
          .timeout(_uploadTimelimit);
      logger.i(res);
    } on AppwriteException catch (eApp) {
      throw ConnectionException(
          cause: eApp.message, code: eApp.code, type: eApp.type);
    } catch (e) {
      logger.e("Error creating file $e");
      rethrow;
    }
  }

  @override
  Future deleteFile({required String bucket, required String fileId}) async {
    try {
      await storage
          .deleteFile(bucketId: bucket, fileId: fileId)
          .timeout(_downLoadTimelimit);
    } on AppwriteException catch (eApp) {
      throw ConnectionException(
          cause: eApp.message, code: eApp.code, type: eApp.type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<File> downloadFile(
      {required String bucket, required String fileId}) async {
    try {
      final resBytes = await storage
          .getFileDownload(bucketId: bucket, fileId: fileId)
          .timeout(_downLoadTimelimit);
      // create a temp file
      final path = await _tempDir;
      final file = File('$path/$fileId');
      await file.writeAsBytes(resBytes);
      return file;
    } on AppwriteException catch (eApp) {
      throw ConnectionException(
          cause: eApp.message, code: eApp.code, type: eApp.type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future getFileDescription() {
    // TODO: implement getFileDescription
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {
    logger.i("Init Appwrite MediaStorage");
    await Hive.initFlutter();
    await initMedia();
  }

  @override
  Logger get logger => Logger();

  @override
  Set<String> buckets;

  @override
  Future<List<FileProxy>> getFileList({required String bucket}) async {
    final list =
        await storage.listFiles(bucketId: bucket).timeout(_downLoadTimelimit);

    final res = list.files.map((e) {
      return FileProxy(
        bucketId: e.bucketId,
        fileId: e.$id,
        name: e.name,
        // withData: false,
        mimeType: e.mimeType,
        // content: Uint8List(0)
      );
    }).toList();
    return res;
  }
}
