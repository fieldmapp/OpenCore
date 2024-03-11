import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({
    super.key,
    required this.needsSyncCallBack,
    required this.entry,
  });

  final Future<bool> Function({required String id}) needsSyncCallBack;
  final Document entry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: needsSyncCallBack(id: entry.$id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          var label = const Text("synced");
          var icon = const Icon(
            Icons.check_rounded,
            size: 16,
          );
          var color = Colors.green.shade200;
          if (snapshot.data!) {
            label = const Text("needs sync");
            icon = const Icon(Icons.sync_rounded, size: 16);
            color = Colors.orange.shade300;
          }
          return FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                  backgroundColor: color,
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontSize: 10)),
              onPressed: () {},
              icon: icon,
              label: label);
        }
        return FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.grey,
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 10)),
            onPressed: () {},
            icon: const Icon(
              Icons.warning_rounded,
              size: 16,
            ),
            label: const Text("loading..."));
      },
    );
  }
}
