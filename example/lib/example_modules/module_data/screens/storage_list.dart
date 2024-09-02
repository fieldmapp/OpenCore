// import 'package:example/example_modules/module_data/controller/media_list.controller.dart';
// import 'package:example/example_modules/module_data/module_data.dart';
// import 'package:example/example_modules/module_data/service/media.service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:open_core/core.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:go_router/go_router.dart';

// class StorageList extends ModulePage<DataModule> {
//   final String id;

//   const StorageList({super.key, required this.id, required super.module});

//   @override
//   Widget build(BuildContext context) {
//     return StorageListConsumer(id: id);
//   }
// }

// class StorageListConsumer extends ConsumerWidget {
//   const StorageListConsumer({
//     super.key,
//     required this.id,
//   });
//   final String id;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final mediaProvider = mediaListControllerProvider(id);
//     final mediaList = ref.watch(mediaProvider);

//     return Scaffold(
//         appBar: AppBar(title: Text("Bucket $id")),
//         body: mediaList.when(
//           data: (resData) {
//             final List<Widget> mediaElements = [];

//             final newBtn = ElevatedButton(
//                 child: const Text("new"),
//                 onPressed: () async {
//                   FilePickerResult? res =
//                       await FilePicker.platform.pickFiles(withData: true);
//                   if (res != null) {
//                     PlatformFile file = res.files.first;
//                     await ref.read(mediaProvider.notifier).uploadFile(
//                         fileName: file.name,
//                         bucketId: id,
//                         fileBytes: file.bytes!);
//                   }
//                 });

//             for (final entry in resData) {
//               mediaElements.add(Material(
//                   surfaceTintColor: Colors.blue,
//                   elevation: 2,
//                   borderRadius: BorderRadius.circular(10),
//                   clipBehavior: Clip.antiAlias,
//                   child: GestureDetector(
//                     onTap: () {
//                       showDialog<void>(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                               title: Text(entry.name),
//                               content: FutureBuilder(
//                                   future: ref
//                                       .read(mediaProvider.notifier)
//                                       .getFile(fileId: entry.fileId),
//                                   builder: (context, snapshot) {
//                                     if (snapshot.connectionState ==
//                                         ConnectionState.done) {
//                                       return snapshot.hasData
//                                           ? Column(
//                                               children: [
//                                                 IconButton(
//                                                     onPressed: () async {
//                                                       await ref
//                                                           .read(mediaProvider
//                                                               .notifier)
//                                                           .removeFile(
//                                                               bucketId: entry
//                                                                   .bucketId,
//                                                               fileId:
//                                                                   entry.fileId);
//                                                       if (context.mounted) {
//                                                         context.pop();
//                                                       }
//                                                     },
//                                                     icon: const Icon(
//                                                         Icons.delete)),
//                                                 Image.memory(snapshot.data!),
//                                               ],
//                                             )
//                                           : const InfoContainer(
//                                               title: "Error",
//                                               subTitle:
//                                                   "Something went wrong fetching your file.",
//                                               icon: Icon(Icons.error_rounded));
//                                     }

//                                     return const Center(
//                                         child: CircularProgressIndicator());
//                                   }));
//                         },
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           const Text("File",
//                               style: TextStyle(
//                                   fontSize: 10, fontWeight: FontWeight.bold)),
//                           Column(
//                             children: [
//                               Text(
//                                 entry.name,
//                                 style: const TextStyle(
//                                     overflow: TextOverflow.ellipsis,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.normal),
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     entry.mimeType,
//                                     style: const TextStyle(
//                                         overflow: TextOverflow.ellipsis,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.normal),
//                                   ),
//                                   FutureBuilder(
//                                       future: MediaService()
//                                           .needsSync(fileId: entry.fileId),
//                                       builder: (context, snapshot) {
//                                         if (snapshot.connectionState ==
//                                             ConnectionState.done) {
//                                           final isSynced =
//                                               snapshot.data ?? false;
//                                           return isSynced
//                                               ? const Icon(
//                                                   Icons.change_circle_rounded)
//                                               : const Icon(
//                                                   Icons.check_box_rounded);
//                                         }
//                                         return const Icon(
//                                             Icons.question_mark_rounded);
//                                       }),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   )));
//             }
//             if (mediaElements.isEmpty) {
//               mediaElements.add(const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [Text("No data!")]));
//             }
//             // add spacer
//             mediaElements.add(newBtn);
//             mediaElements.add(const SizedBox(
//               height: 300,
//             ));
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: ListView.separated(
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     return mediaElements.elementAt(index);
//                   },
//                   separatorBuilder: (context, index) => const SizedBox(
//                         height: 16,
//                       ),
//                   itemCount: mediaElements.length),
//             );
//           },
//           error: (error, stackTrace) {
//             return Center(
//                 child: InfoContainer(
//                     icon: const Icon(Icons.error),
//                     title: "Something went wrong",
//                     subTitle: error.toString()));
//           },
//           loading: () {
//             return const Center(child: CircularProgressIndicator());
//           },
//         ));
//   }
// }
