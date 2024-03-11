import 'package:example/example_modules/module_simple.dart';
import 'package:example/example_modules/root_module.dart';
import 'package:flutter/material.dart';
import 'package:open_core/core.dart';

Future<RootModule> setupSimpleModule() async {
  // scaffold key to be injected
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final mainMod = await MainModule.fromConfig(dependencies: [
    // // GLOBAL scaffold key
    ModuleDependency<GlobalKey<ScaffoldMessengerState>>(toInject: scaffoldKey),
  ], subModules: [
    SimpleModule()
  ]);

  return mainMod;
}
