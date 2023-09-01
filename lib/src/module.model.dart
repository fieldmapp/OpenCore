import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:open_core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:open_core/src/exceptions/module_exception.dart';

final _logger = Logger();

abstract class ModuleRoutes {
  const ModuleRoutes({required this.path, required this.completeFragment});
  final String path;
  final String completeFragment;

  String get absolutePath;
}

class ModuleDependency<T extends Object> {
  final T? toInject;
  ModuleDependency({this.toInject});

  void inject() {
    if (toInject == null) {
      _logger.d("can not inject null");
      throw ModuleException(
          cause: "Failed to inject dependency, because Injection Value is null",
          type: ModuleExceptionType.injection);
    }
    GetIt.I.registerLazySingleton<T>(() => toInject!);
  }

  bool isRegistered() {
    return GetIt.I.isRegistered<T>();
  }

  Type get dependencyType => T;
}

/// TODO: Maybe a builder or fluent interface for the Module creation?
abstract class AppModule {
  // final GetIt locator = GetIt.I;

  Logger get logger => _logger;

  String get moduleName;

  // atm we need to rely that the implementation of AppModule
  // list all dependencies used in the module
  List<ModuleDependency> get dependencies;

  Map<ModuleRoutes, ModulePageBuilder> get modulePages;

  RouteBase get routes;

  ModuleRoutes get root;

  List<ModuleRoutes> get moduleRoutes;

  /// Optional, if the getter gets implemented that Navbaritem is registered in the Global list of TabItems
  /// and can then be used to render a bottom navbar with those items
  ScaffoldWithNavBarTabItem? get tab;

  bool isInit = false;

  /// A GetIt Wrapper which throws a custom ex. on failure
  T getDependency<T extends Object>() {
    for (final dep in dependencies) {
      if (dep.dependencyType == T) {
        try {
          return GetIt.I.get<T>();
        } on Exception catch (e) {
          final cause =
              "Failed to get Dependency of Type $T, see ${e.toString()}";
          logger.e(cause);
          throw ModuleException(
              cause: "Failed to get Dependency of Type $T, see ${e.toString()}",
              type: ModuleExceptionType.dependency);
        }
      }
    }
    final cause =
        "Failed to get Dependency of Type $T, not part of the Dependency List of this Module!";
    logger.e(cause);
    throw ModuleException(cause: cause, type: ModuleExceptionType.dependency);
  }

  AppModule();

  /// Always add the Generic [T] in order for to retrive it correctly via get_it
  FutureOr<void> init<T extends AppModule>() async {
    if (!isInit) {
      _logger.d("init Module $moduleName");
      checkDeps();
      // to do add params. or overload for lazy registration
      GetIt.I.registerSingleton<T>(this as T, instanceName: moduleName);
      isInit = true;
    } else {
      _logger.d("Module $moduleName is already initialized!");
    }
  }

  /// Checks if all Dependencies for this Module are set.
  void checkDeps() {
    for (final dep in dependencies) {
      _logger.d("Is ${dep.dependencyType} registered?");
      final res = dep.isRegistered();
      if (!res) {
        final err = ModuleException(
            cause: "Dependency ${dep.dependencyType} for $moduleName not met!",
            type: ModuleExceptionType.dependency);
        _logger.e(err.cause, [err]);
        throw err;
      }
    }
  }

  /// This Method builds the routing structure of the Module defined in the [modulePages] Map.
  /// The routing structure is lead by the root Route and followed by its subroutes.
  ///   - /root
  ///     - /subroute1
  ///     - /subroute2
  ///
  /// The Method returns a [RouteBase] Object from the [GoRouter Package](https://pub.dev/packages/go_router)
  /// to be compatible with other Modules and Packages.
  /// If you do not want to use the implemented Routing-Structure here just override this Method with your own
  /// custom GoRouting [RouteBase] Object.
  @protected
  RouteBase buildRoutes() {
    try {
      final subroutes = modulePages.entries
          .where((element) =>
              element.key !=
              root) // filter root bc we dont want to add it twice
          .map(
            (e) => GoRoute(
                path: e.key.path,
                builder: e.value.builder,
                pageBuilder: e.value.pagebuilder),
          )
          .toList();
      return GoRoute(
          path: root.absolutePath,
          builder: modulePages[root]!.builder,
          pageBuilder: modulePages[root]!.pagebuilder,
          routes: subroutes);
    } on Exception catch (eRoute) {
      final cause =
          "Something went wrong creating the routes for Module: $moduleName, see $eRoute";
      logger.e(cause, eRoute);
      throw ModuleException(
          cause: cause, type: ModuleExceptionType.initialization);
    }
  }
}

abstract class RootModule extends AppModule {
  /// Extension of a [AppModule] to setup multiple Modules within this structure
  /// initalizes all SubModules, Routes and Dependencies on creation

  final List<AppModule> subModules;
  @override
  final List<ModuleDependency> dependencies;

  GoRouter get router;

  RootModule({required this.subModules, required this.dependencies}) : super();

  static Future<RootModule> fromConfig(
      {required List<AppModule> subModules,
      required List<ModuleDependency> dependencies}) {
    throw UnimplementedError();
  }

  @override
  FutureOr<void> init<T extends AppModule>() async {
    if (!isInit) {
      _logger.d("init RootModule $moduleName");
      _setupDependencies(dependencies);
      _setupModules(subModules);
      GetIt.I.registerSingleton<T>(this as T, instanceName: moduleName);
      checkDeps();
      isInit = true;
      _logger.d("RootModule $moduleName initialized");
    } else {
      _logger.d("RootModule $moduleName is already initialized!");
    }
  }

  void _setupDependencies(List<ModuleDependency> dependencies) {
    for (final dep in dependencies) {
      _logger.d("injecting ${dep.toInject.runtimeType}");
      dep.inject();
    }
  }

  FutureOr<void> _setupModules(List<AppModule> modules) async {
    GetIt locator = GetIt.I;
    final tabs = [];
    final List<RouteBase> routes = [];
    for (final mod in modules) {
      await mod.init();
      tabs.add(mod.tab);
      routes.add(mod.routes);
    }
    // register tab entry for bottom nav
    locator.registerLazySingleton<List<ScaffoldWithNavBarTabItem>>(
      () {
        return tabs.whereType<ScaffoldWithNavBarTabItem>().toList();
      },
    );
    // register module routes
    locator.registerLazySingleton<List<RouteBase>>(() {
      return routes;
    }, instanceName: moduleName);
  }

  /// Same as in [buildRoutes] in the [AppModule] this method can be overwritten, but a [RootModule] should
  /// always be implemented as [ShellRoute] to ensure the correct scoping of the created routes
  @override
  RouteBase buildRoutes() {
    List<RouteBase> moduleRoutes = [];
    final logger = Logger();
    try {
      logger.i("Getting routes for $moduleName");
      moduleRoutes = GetIt.I.get<List<RouteBase>>(instanceName: moduleName);
    } catch (e) {
      logger.e("Error getting module Routes of $moduleName.");
    }
    try {
      final rootSubroutes = modulePages.entries
          .map(
            (e) => GoRoute(
                path: e.key.absolutePath,
                builder: e.value.builder,
                pageBuilder: e.value.pagebuilder),
          )
          .toList();
      return ShellRoute(
          builder: (context, state, child) => Scaffold(body: child),
          routes: [
            ...rootSubroutes,
            // add sub module routes
            ...moduleRoutes
          ]);
    } on Exception catch (eRootMod) {
      final cause =
          "Something went wrong creating the routes for RootModule: $moduleName, see $eRootMod";
      logger.e(cause, eRootMod);
      throw ModuleException(
          cause: cause, type: ModuleExceptionType.initialization);
    }
  }
}
