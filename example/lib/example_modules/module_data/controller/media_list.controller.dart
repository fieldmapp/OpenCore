// // declare a part file
// import 'dart:typed_data';

// import 'package:example/example_modules/module_data/service/media.service.dart';
// import 'package:open_core/core.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'media_list.controller.g.dart';
// // generate with: dart run build_runner watch

// @riverpod
// class MediaListController extends _$MediaListController {
//   List<FileProxy> _currentList = [];
//   MediaService mediaService = MediaService();

//   @override
//   // note the [Future] return type and the async keyword
//   Future<List<FileProxy>> build(String bucketId) async {
//     _currentList = await getFiles(bucketId: bucketId);
//     return _currentList;
//   }

//   Future<List<FileProxy>> getFiles({required String bucketId}) async {
//     state = const AsyncLoading();
//     _currentList = await mediaService.listFilesOfBucket(bucket: bucketId);
//     state = AsyncData(_currentList);
//     return _currentList;
//   }

//   Future<Uint8List> getFile({required String fileId}) async {
//     final res = await mediaService.getFile(bucketId: bucketId, fileId: fileId);
//     return res;
//   }

//   Future<void> uploadFile(
//       {required String bucketId,
//       required String fileName,
//       required Uint8List fileBytes}) async {
//     state = const AsyncLoading();
//     try {
//       final fileProxy = await mediaService.createUpload(
//           fileName: fileName, bucketId: bucketId, fileBytes: fileBytes);
//       _currentList.add(fileProxy);
//       state = AsyncData(_currentList);
//     } on Exception catch (e) {
//       state = AsyncError(e, StackTrace.current);
//     }
//   }

//   Future<void> removeFile(
//       {required String bucketId, required String fileId}) async {
//     state = const AsyncLoading();
//     await mediaService.removeFile(bucketId: bucketId, fileId: fileId);
//     _currentList =
//         _currentList.where((element) => element.fileId != fileId).toList();
//     state = AsyncData(_currentList);
//   }
// }
