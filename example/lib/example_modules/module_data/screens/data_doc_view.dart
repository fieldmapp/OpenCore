import 'package:example/example_modules/module_data/controller/doc.controller.dart';
import 'package:example/example_modules/module_data/module_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_core/core.dart';
import 'package:go_router/go_router.dart';

class DataDocView extends ModulePage<DataModule> {
  final String docID;
  final String collectionID;
  final String? revision;

  const DataDocView({
    super.key,
    required super.module,
    required this.docID,
    required this.collectionID,
    this.revision,
  });

  @override
  Widget build(BuildContext context) {
    return DataDocViewConsumer(
      collectionID: collectionID,
      docID: docID,
      revision: revision,
    );
  }
}

class DataDocViewConsumer extends ConsumerWidget {
  const DataDocViewConsumer({
    super.key,
    required this.docID,
    required this.collectionID,
    this.revision,
  });

  final String docID;
  final String collectionID;
  final String? revision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    final docProvider = docControllerProvider(collectionID, docID, revision);
    final doc = ref.watch(docProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("DOC")),
      floatingActionButton: ExpandableFab(distance: 60, children: [
        ActionButton(
            onPressed: () async {
              await ref.read(docProvider.notifier).removeDoc(
                  collectionId: collectionID,
                  docId: docID,
                  revisionId: revision!);
              if (context.mounted) {
                context.pop();
              }
            },
            icon: const Icon(Icons.delete_rounded)),
        ActionButton(
            onPressed: () async {
              await ref
                  .read(docProvider.notifier)
                  .updateDoc(data: {"Name": "Eric"});
            },
            icon: const Icon(Icons.update_rounded))
      ]),
      body: doc.when(
          data: (currentDoc) {
            return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: RefreshIndicator(
                    onRefresh: (() async {
                      await ref.read(docProvider.notifier).getNewestVersion();
                    }),
                    child: ListView.builder(
                        itemCount: currentDoc.data.length,
                        itemBuilder: (context, index) {
                          var val = currentDoc.data.values
                              .elementAt(index)
                              .toString();
                          final field = currentDoc.data.keys.elementAt(index);
                          final isNum = isNumeric(val);
                          // TODO implement actual change detection with history
                          // - history controller
                          // - workflow when to update values
                          Widget valWidget = field.startsWith("\$")
                              ? Text(val, overflow: TextOverflow.ellipsis)
                              : TextFormField(
                                  keyboardType: isNum
                                      ? TextInputType.number
                                      : TextInputType.text,
                                  inputFormatters: isNum
                                      ? [FilteringTextInputFormatter.digitsOnly]
                                      : [],
                                  onChanged: (value) {
                                    val = value;
                                  },
                                  onFieldSubmitted: (value) async {
                                    await ref
                                        .read(docProvider.notifier)
                                        .updateDoc(data: {field: value});
                                  },
                                  initialValue: val,
                                  decoration: InputDecoration(
                                      hintText: field,
                                      hintStyle: const TextStyle(
                                          color: Colors.grey, fontSize: 12.0)),
                                  style: const TextStyle(
                                      fontFamily: "Poppins-Bold"));
                          return Material(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    field,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  valWidget
                                ]),
                          ));
                        }),
                  ))
                ]);
          },
          error: (error, stackTrace) => Center(
                  child: Column(
                children: [
                  InfoContainer(
                      icon: Icons.error,
                      title: "Something went wrong",
                      subTitle: stackTrace.toString()),
                  TextButton(
                      onPressed: () {
                        ref.read(docProvider.notifier).getNewestVersion();
                      },
                      child: const Text("Back to doc"))
                ],
              )),
          loading: () => const Center(child: CircularProgressIndicator())),
    );
  }
}

bool isNumeric(String s) {
  return double.tryParse(s) != null;
}
