import 'package:flutter/material.dart';
import 'package:open_core/core.dart';

class SimpleModule extends AppModule {
  @override
  InternalModuleLink get internalLinks => InternalModuleLink(
      root: ModuleRoutes(
          path: "simple",
          completeFragment: "/simple",
          modName: moduleName,
          pageBuilder: ModulePageBuilder(
              builder: (context, state) => SimpleModulePage(module: this))));

  @override
  // no dependencies for this example module
  List<ModuleDependency<Object>> get dependencies => [];

  @override
  String get moduleName => runtimeType.toString();

  @override
  // no nav item needed
  ScaffoldWithNavBarTabItem? get tab => null;

  @override
  // no external links
  ExternalModuleLink? get externalLinks => null;
}

class SimpleModulePage extends ModulePage<SimpleModule> {
  const SimpleModulePage({super.key, required super.module});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Hello Simple Page!")));
  }
}
