import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_core/core.dart';

class TestModule extends AppModule {
  TestModule() {
    print("Setup MOD A");
  }

  static String name = "test";

  @override
  String get moduleName => runtimeType.toString();

  @override
  List<ModuleDependency> get dependencies =>
      [ModuleDependency<ApiAuthRepository>()];

  @override
  RouteBase get routes => buildRoutes(locator);

  @override
  ModuleRoutes get root => Routes.root;

  @override
  List<ModuleRoutes> get moduleRoutes => Routes.values;

  @override
  ScaffoldWithNavBarTabItem? get tab => ScaffoldWithNavBarTabItem(
        initialLocation: Routes.root.absolutePath,
        icon: const Icon(Icons.home),
        label: 'Section A',
      );
}
