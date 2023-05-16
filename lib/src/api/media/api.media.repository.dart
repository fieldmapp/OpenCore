import 'dart:io';
import 'package:core/src/api/media/file_adapater.dart';
import 'package:core/src/api/media/MediaService.extension.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

abstract class ApiMedia {
  late final Set<String> buckets;
  final logger = Logger();

  Future<void> init();

  @protected
  Future createFile(
      {required String bucket, required String fileId, required File file});

  @protected
  Future deleteFile({required String bucket, required String fileId});

  @protected
  Future<List<FileProxy>> getFileList({required String bucket});

  @protected
  Future<File> downloadFile({required String bucket, required String fileId});

  @protected
  Future getFileDescription();
}

abstract class ApiMediaRepository extends Media {}
