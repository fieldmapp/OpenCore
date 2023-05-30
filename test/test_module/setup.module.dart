import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_core/core.dart';
import 'routes.dart';

class TestModule extends AppModule {
  TestModule() {
    logger.i("Setup Test Mod");
  }

  @override
  String get moduleName => runtimeType.toString();

  @override
  List<ModuleDependency> get dependencies => [];

  // [ModuleDependency<ApiAuthRepository>()];

  @override
  RouteBase get routes => buildRoutes();

  @override
  ModuleRoutes get root => TestModRoutes.root;

  @override
  List<ModuleRoutes> get moduleRoutes => TestModRoutes.values;

  @override
  ScaffoldWithNavBarTabItem? get tab => ScaffoldWithNavBarTabItem(
        initialLocation: TestModRoutes.root.absolutePath,
        icon: const Icon(Icons.home),
        label: 'Test Section',
      );

  @override
  RouteBase buildRoutes() {
    return GoRoute(
      path: TestModRoutes.root.path,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: Placeholder()),
      routes: [
        GoRoute(
          path: TestModRoutes.details.path,
          builder: (context, state) => const Placeholder(),
        ),
      ],
    );
  }
}
