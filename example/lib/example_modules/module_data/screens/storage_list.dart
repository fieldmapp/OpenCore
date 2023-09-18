import 'package:example/example_modules/module_data/module_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:open_core/core.dart';

class StorageList extends ModulePage<DataModule> {
  final String id;

  const StorageList({super.key, required this.id, required super.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("StorageList $id")),
    );
  }
}
