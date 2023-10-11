import 'package:example/example_modules/module_data/module_data.dart';
import 'package:example/example_modules/module_data/service/doc.service.dart';
import 'package:example/example_modules/module_data/service/media.service.dart';
import 'package:example/example_modules/module_data/widgets/data_cache_op_list.dart';
import 'package:flutter/material.dart';
import 'package:open_core/core.dart';
import 'package:go_router/go_router.dart';

class DataListView extends ModuleLandingPage<DataModule> {
  DataListView({super.key, required super.module, required super.hasBottomBar});

  @override
  Widget build(BuildContext context) {
    final dbApi = module.getDependency<ApiDataRepository>();
    final mediaApi = module.getDependency<ApiMediaRepository>();
    final List<Widget> collectionLinks = module.collections.map(
      (e) {
        return ElevatedButton(
          onPressed: () => context
              .push("${module.internalLinks.collection.absolutePath}/$e"),
          child: Column(
            children: [
              const Text("Collection",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text(e),
            ],
          ),
        );
      },
    ).toList();

    final List<Widget> bucketLinks = module.buckets.map(
      (e) {
        return ElevatedButton(
          onPressed: () =>
              context.push("${module.internalLinks.bucket.absolutePath}/$e"),
          child: Column(
            children: [
              const Text("Bucket",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              Text(e),
            ],
          ),
        );
      },
    ).toList();

    return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("DataListview"),
              ElevatedButton(
                onPressed: () => dbApi.addNewCollectionEntry(entryName: "test"),
                child: const Text("New Box!",
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              ...collectionLinks,
              ...bucketLinks
            ],
          ),
        ),
        floatingActionButton: ExpandableFab(distance: 80, children: [
          ActionButton(
            onPressed: () {
              showModalBottomSheet<void>(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  isScrollControlled: true,
                  enableDrag: true,
                  builder: (BuildContext context) {
                    // return getCacheOpList();
                    return CacheOperationList<DataCacheOperation>(
                      getOpStream: () =>
                          dbApi.cacheOperationStream<DataCacheOperation>(),
                      pathToDoc: module.internalLinks.doc.absolutePath,
                      syncChanges: () => dbApi.syncLocalChanges(),
                      listBuilder: (
                              {required basePath,
                              required isSyncing,
                              required valueMap}) =>
                          DataCacheOpListView(
                              valueMap: valueMap,
                              isSyncing: isSyncing,
                              pathToDoc: basePath),
                    );
                  });
            },
            icon: const Icon(Icons.change_circle),
          ),
          ActionButton(
            onPressed: () {
              showModalBottomSheet<void>(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  isScrollControlled: true,
                  enableDrag: true,
                  builder: (BuildContext context) {
                    // return getCacheOpList();
                    return CacheOperationList<FileCacheOperation>(
                      getOpStream: () =>
                          mediaApi.cacheOperationStream<FileCacheOperation>(),
                      pathToDoc: module.internalLinks.doc.absolutePath,
                      syncChanges: () => mediaApi.syncLocalChanges(),
                      listBuilder: (
                              {required basePath,
                              required isSyncing,
                              required valueMap}) =>
                          FileCacheOpListview(
                              valueMap: valueMap,
                              isSyncing: isSyncing,
                              pathToDoc:
                                  module.internalLinks.bucket.absolutePath),
                    );
                  });
            },
            icon: const Icon(Icons.perm_media_rounded),
          ),
          ActionButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              await DocService().resetDataCache();
              await MediaService().resetMediaCache();
            },
          )
        ]));
  }
}
