import 'package:open_core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

abstract class ModuleRoutes {
  const ModuleRoutes(
      {required this.parentModule,
      required this.path,
      required this.absolutePath});
  final String path;
  final String absolutePath;
  final String parentModule;
}

class ModuleDependency<T extends Object> {
  final T? toInject;
  ModuleDependency({this.toInject});

  void inject() {
    if (toInject == null) {
      _logger.d("can not inject null");
      return;
    }
    GetIt.I.registerLazySingleton<T>(() => toInject!);
  }

  bool isRegistered() {
    return GetIt.I.isRegistered<T>();
  }

  Type get dependencyType => T;
}

abstract class AppModule {
  final GetIt locator = GetIt.I;

  Logger get logger => _logger;

  String get moduleName;

  // atm we need to rely that the implementation of AppModule
  // list all dependencies used in the module
  List<ModuleDependency> get dependencies;

  RouteBase get routes;

  ModuleRoutes get root;

  List<ModuleRoutes> get moduleRoutes;

  ScaffoldWithNavBarTabItem? get tab;

  bool isInit = false;

  AppModule();

  void init<T extends AppModule>() {
    if (!isInit) {
      _logger.d("init Module $moduleName");
      checkDeps();
      // to do add params. or overload for lazy registration
      locator.registerSingleton<T>(this as T, instanceName: moduleName);
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
        final err = Exception(
            "Dependency ${dep.dependencyType} for $moduleName not met!");
        _logger.e(
            "Dependency ${dep.dependencyType} for $moduleName not met!", [err]);
        throw err;
      }
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

  @override
  void init<T extends AppModule>() {
    if (!isInit) {
      _logger.d("init RootModule $moduleName");
      _setupDependencies(dependencies);
      _setupModules(subModules);
      locator.registerSingleton<T>(this as T, instanceName: moduleName);
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

  void _setupModules(List<AppModule> modules) {
    GetIt locator = GetIt.I;
    final tabs = [];
    final List<RouteBase> routes = [];
    for (final mod in modules) {
      mod.init();
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
}
