part of core;

final _logger = Logger();

class ModuleRouteBase {
  const ModuleRouteBase(
      {required this.path,
      required this.completeFragment,
      required this.modName});
  final String path;
  final String completeFragment;
  final String modName;

  String get absolutePath => "/$modName$completeFragment";
}

class ModuleRoutes extends ModuleRouteBase {
  const ModuleRoutes(
      {required this.pageBuilder,
      required super.path,
      required super.completeFragment,
      required super.modName});

  final ModulePageBuilder pageBuilder;

  factory ModuleRoutes.fromModuleRouteBase(
      {required ModuleRouteBase routeBase,
      required ModulePageBuilder pageBuilder}) {
    return ModuleRoutes(
        pageBuilder: pageBuilder,
        path: routeBase.path,
        completeFragment: routeBase.completeFragment,
        modName: routeBase.modName);
  }
}

class ModuleDependency<T extends Object> {
  final T? toInject;
  final String? dependcyName;
  ModuleDependency({this.toInject, this.dependcyName});

  void inject() {
    if (toInject == null) {
      _logger.d("can not inject null");
      throw ModuleException(
          cause: "Failed to inject dependency, because Injection Value is null",
          type: ModuleExceptionType.injection);
    }
    GetIt.I
        .registerLazySingleton<T>(instanceName: dependcyName, () => toInject!);
  }

  bool isRegistered() {
    return GetIt.I.isRegistered<T>(instanceName: dependcyName);
  }

  Type get dependencyType => T;
}

/// Helper Class which can be used to define links to other Modules or Pages
/// outside of this Module.
/// Idea is to Extend this class when a new Module is defined.
///
/// ```dart
/// class ModuleAExternalLinks extends ExternalModuleLink {
///   ModuleAExternalLinks({required super.home, required this.linkToModuleB});
///   final ModuleRoutes linkToModuleB;
/// }
/// // usage
/// final modA = ModuleA(externalModuleLink: ModuleAExternalLinks(
///         home: RootRoutes.root, linkToModuleB: ModuleBRoutes.root)
/// // called with
/// modA.externalLinks.home
/// ```
///
class ExternalModuleLink {
  final ModuleRouteBase home;
  ExternalModuleLink({required this.home});
}

/// Same as [ExternalModuleLink] but for Module internal Routing
class InternalModuleLink {
  final ModuleRoutes root;
  InternalModuleLink({required this.root});

  /// Maps each [ModuleRoutes] defined for this Module to an actual Page implementation
  /// a Page implementation should be of Type [ModulePage] or [ModuleLandingPage]
  /// which are wrapper for StatelessWidgets which require the Parent Module as constructor input
  Map<ModuleRoutes, ModulePageBuilder> get pages =>
      Map.of({root: root.pageBuilder});
}

/// TODO: Maybe a builder or fluent interface for the Module creation?
abstract class AppModule {
  AppModule({ExternalModuleLink? externalModuleLink});
  Logger get logger => _logger;

  String get moduleName;

  // atm we need to rely that the implementation of AppModule
  // list all dependencies used in the module
  List<ModuleDependency> get dependencies;

  RouteBase get routes => buildRoutes();

  /// (optional) Contains all routes/links to Modules/Widgets/Pages outside of this Module
  ExternalModuleLink? get externalLinks;

  /// TODO: is it worth it? Benefit i see from that implementation is type safety
  /// for accessing Routes within a Module and the api is similar to externalLinks
  /// but the creation is more boilerplate than before
  InternalModuleLink get internalLinks;

  /// Optional, if the getter gets implemented that Navbaritem is registered in the Global list of TabItems
  /// and can then be used to render a bottom navbar with those items
  ScaffoldWithNavBarTabItem? get tab;

  bool isInit = false;

  List<ModuleService> moduleServices = [];

  /// A GetIt Wrapper which throws a custom ex. on failure
  T getDependency<T extends Object>({String? dependencyName}) {
    // name and type
    Iterable<ModuleDependency<Object>> res;
    if (dependencyName != null) {
      res = dependencies.where((element) =>
          element.dependcyName == dependencyName &&
          element.dependencyType == T);
    } else {
      // type only
      res = dependencies.where((element) => element.dependencyType == T);
    }

    if (res.isEmpty) {
      final cause =
          "Failed to get Dependency of Type $T, not part of the Dependency List of this Module!";
      logger.e(cause);
      throw ModuleException(cause: cause, type: ModuleExceptionType.dependency);
    }

    try {
      return GetIt.I.get<T>(instanceName: res.first.dependcyName);
    } on Exception catch (e) {
      final cause = "Failed to get Dependency of Type $T, see ${e.toString()}";
      logger.e(cause);
      throw ModuleException(
          cause: "Failed to get Dependency of Type $T, see ${e.toString()}",
          type: ModuleExceptionType.dependency);
    }
  }

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
        _logger.e(err.cause, stackTrace: StackTrace.current);
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
      final subroutes = internalLinks.pages.entries
          .where((element) =>
              element.key !=
              internalLinks.root) // filter root bc we dont want to add it twice
          .map(
            (e) => GoRoute(
                path: e.key.path,
                builder: e.value.builder,
                pageBuilder: e.value.pagebuilder),
          )
          .toList();
      return GoRoute(
          path: internalLinks.root.absolutePath,
          builder: internalLinks.root.pageBuilder.builder,
          pageBuilder: internalLinks.root.pageBuilder.pagebuilder,
          routes: subroutes);
    } on Exception catch (eRoute) {
      final cause =
          "Something went wrong creating the routes for Module: $moduleName, see $eRoute";
      logger.e(cause, stackTrace: StackTrace.current);
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

  // TODO: this needs a rework since i cant enforce the implementation of this method in the implementing
  // class of a RootModule
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
      await _setupModules(subModules);
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
    logger.d("Register routes $moduleName");
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
      final rootSubroutes = internalLinks.pages.entries
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
      logger.e(cause, stackTrace: StackTrace.current);
      throw ModuleException(
          cause: cause, type: ModuleExceptionType.initialization);
    }
  }
}
