import 'package:flutter/material.dart';
import 'package:open_core/core.dart';
import 'package:go_router/go_router.dart';

class CacheOperationList extends StatelessWidget {
  CacheOperationList(
      {super.key,
      required this.getOpStream,
      required this.syncChanges,
      required this.pathToDoc});

  final Stream<Map<String, DataCacheOperation>> Function() getOpStream;
  final Future<void> Function() syncChanges;
  final String pathToDoc;

  final ValueNotifier isSyncing = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getOpStream(),
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data!.entries.isNotEmpty) {
            return SizedBox(
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Local Changes  ",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                "${snapshot.data!.length}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              isSyncing.value = true;
                              await syncChanges();
                              isSyncing.value = false;
                            },
                            icon: const Icon(Icons.refresh)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                        valueListenable: isSyncing,
                        builder: (context, value, child) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final entry =
                                  snapshot.data!.entries.elementAt(index);
                              final opName = entry.value.operationType.name;
                              final docId = entry.value.entryId;

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => context.push(
                                      "$pathToDoc/${entry.value.parentId}/${entry.value.entryId}/${entry.value.revision}"),
                                  child: Material(
                                      elevation: value ? 10 : 1,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                opName,
                                                overflow: TextOverflow.clip,
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              value
                                                  ? const SizedBox(
                                                      height: 15,
                                                      width: 15,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                "Doc: ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(docId,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                            ],
                                          ),
                                          const Divider(),
                                          ...entry.value.data.entries.map((e) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  e.key,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    "${e.value}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            );
                                          }).toList()
                                        ]),
                                      )),
                                ),
                              );
                            },
                          );
                        }),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox(
            height: 300,
            child: Center(
              child: InfoContainer(
                title: "No local changes",
                icon: Icons.air_rounded,
                subTitle: "You can lean back now.",
              ),
            ),
          );
        });
  }
}
