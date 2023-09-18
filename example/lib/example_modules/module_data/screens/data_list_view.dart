import 'package:example/example_modules/module_data/module_data.dart';
import 'package:flutter/material.dart';
import 'package:open_core/core.dart';
import 'package:go_router/go_router.dart';

class DataListView extends ModuleLandingPage<DataModule> {
  DataListView({super.key, required super.module, required super.hasBottomBar});

  @override
  Widget build(BuildContext context) {
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
          ...collectionLinks,
          ...bucketLinks
        ],
      ),
    ));
  }
}
