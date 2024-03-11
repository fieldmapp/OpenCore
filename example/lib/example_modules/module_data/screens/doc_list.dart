import 'package:example/example_modules/module_data/controller/doc_list.controller.dart';
import 'package:example/example_modules/module_data/module_data.dart';
import 'package:example/example_modules/module_data/widgets/sync_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_core/core.dart';
import 'package:go_router/go_router.dart';

class DocList extends ModulePage<DataModule> {
  final String id;

  const DocList({super.key, required this.id, required super.module});

  @override
  Widget build(BuildContext context) {
    return DocListConsumer(id: id, module: module);
  }
}

class DocListConsumer extends ConsumerWidget {
  final String id;
  final DataModule module;
  const DocListConsumer({
    super.key,
    required this.id,
    required this.module,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docProvider = docListControllerProvider(id);
    final docList = ref.watch(docProvider);

    final api = module.getDependency<ApiDataRepository>();
    return Scaffold(
        appBar: AppBar(title: Text("Collection $id")),
        body: docList.when(
          data: (resData) {
            final newBtn = ElevatedButton(
                child: const Text("new"),
                onPressed: () async {
                  final newDoc = await ref
                      .read(docProvider.notifier)
                      .addDoc(collectionId: id, data: {});
                  if (newDoc != null && context.mounted) {
                    context.push(
                        "${module.internalLinks.doc.absolutePath}/$id/${newDoc.$id}/${newDoc.data["revision"]}");
                  }
                });

            final List<Widget> docs = [];

            for (final entry in resData) {
              docs.add(
                GestureDetector(
                  key: UniqueKey(),
                  onLongPress: () async {
                    await HapticFeedback.heavyImpact();
                    await ref.read(docProvider.notifier).removeDoc(
                        collectionId: id,
                        docId: entry.$id,
                        revision: entry.data["revision"]);
                  },
                  onTap: () => context.push(
                      "${module.internalLinks.doc.absolutePath}/${entry.$collectionId}/${entry.$id}/${entry.data["revision"]}"),
                  child: Material(
                      surfaceTintColor: Colors.blue,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(10),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Document",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Text(entry.$id),
                            // causes flickering atm
                            SyncIndicator(
                                key: UniqueKey(),
                                needsSyncCallBack: api.entryNeedsSync,
                                entry: entry)
                          ],
                        ),
                      )),
                ),
              );
            }

            if (docs.isEmpty) {
              docs.add(const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("No data!")]));
            }
            docs.add(newBtn);
            // add spacer
            docs.add(const SizedBox(
              height: 300,
            ));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return docs.elementAt(index);
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 16,
                      ),
                  itemCount: docs.length),
            );
          },
          error: (error, stackTrace) {
            return Center(
                child: InfoContainer(
                    icon: const Icon(Icons.error),
                    title: "Something went wrong",
                    subTitle: error.toString()));
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
