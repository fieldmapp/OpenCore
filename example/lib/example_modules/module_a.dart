import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_core/core.dart';
import 'package:get_it/get_it.dart';

class ModuleA extends AppModule {
  ModuleA({required ModuleAExternalLinks externalModuleLink}) {
    _externalLinks = externalModuleLink;
  }
  @override
  RouteBase buildRoutes() {
    // remove default implementation or implement your own RouteBase object here
    return super.buildRoutes();
  }

  @override
  List<ModuleDependency<Object>> get dependencies =>
      [ModuleDependency<ApiAuthRepository>()];

  @override
  String get moduleName => runtimeType.toString();

  @override
  ScaffoldWithNavBarTabItem? get tab => ScaffoldWithNavBarTabItem(
        initialLocation: internalLinks.root.absolutePath,
        icon: const Icon(Icons.home),
        label: 'Section A',
      );

  @protected
  late final ModuleAExternalLinks _externalLinks;
  @override
  ModuleAExternalLinks get externalLinks {
    return _externalLinks;
  }

  set externalLinks(ModuleAExternalLinks externalLinks) {
    _externalLinks = externalLinks;
  }

  @override
  List<ModuleService<AppModule>> get moduleServices =>
      [ModuleAService(module: this)];

  @override
  ModuleAInternalLinks get internalLinks => ModuleAInternalLinks(
      root: ModuleRoutes.fromModuleRouteBase(
        routeBase: ModuleAInternalLinks.staticRoot,
        pageBuilder: ModulePageBuilder(pagebuilder: (context, state) {
          return NoTransitionPage(
              child: AnotherScreen(
                  module: this, key: UniqueKey(), hasBottomBar: true));
        }),
      ),
      details: ModuleRoutes.fromModuleRouteBase(
          routeBase: ModuleAInternalLinks.staticDetail,
          pageBuilder: ModulePageBuilder(builder: (context, state) {
            return AnotherDetail(module: this, key: UniqueKey());
          })));
}

class ModuleAExternalLinks extends ExternalModuleLink {
  ModuleAExternalLinks({required super.home, required this.linkToModuleB});
  final ModuleRouteBase linkToModuleB;
}

class ModuleAInternalLinks extends InternalModuleLink {
  ModuleAInternalLinks({required super.root, required this.details});
  // defining those as statics helps in order to base them as ExternalLinks but it
  // that is not absolutly mandatory
  static ModuleRouteBase staticRoot = const ModuleRouteBase(
      path: "a", completeFragment: "/a", modName: "ModuleA");
  static ModuleRouteBase staticDetail = const ModuleRouteBase(
      path: "detail", completeFragment: "/a/detail", modName: "ModuleA");
  final ModuleRoutes details;

  @override
  Map<ModuleRoutes, ModulePageBuilder> get pages {
    final pages = super.pages;
    pages[details] = details.pageBuilder;
    return pages;
  }
}

// Test Service
class ModuleAService extends ModuleService<ModuleA> {
  ModuleAService({required super.module});

  void test() {
    print("Hello! Module A is initialized: ${module.isInit}");
  }
}

// Test Pages
class AnotherDetail extends ModulePage<ModuleA> {
  const AnotherDetail({super.key, required super.module});

  @override
  Widget build(BuildContext context) {
    // final authApi = module.getDependency<ApiAuthRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Another Detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Another Detail"),
            // Text("${authApi.getUser()?.email}"),
            ElevatedButton(
                onPressed: () => {context.pop()}, child: const Text("Back"))
          ],
        ),
      ),
    );
  }
}

class AnotherScreen extends ModuleLandingPage<ModuleA> {
  AnotherScreen(
      {super.key, required super.hasBottomBar, required super.module});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final String location = getCurrentLocation(router: router);
    final tabs = GetIt.I.get<List<ScaffoldWithNavBarTabItem>>();
    // computes the current index from the current location
    final currentIndex = locationToTabIndex(location, tabs);
    return Scaffold(
      appBar: AppBar(title: const Text('Another Screen')),
      bottomNavigationBar: hasBottomBar
          ? BottomNavigationBar(
              backgroundColor: Colors.amber,
              currentIndex: currentIndex,
              items: tabs,
              onTap: (index) =>
                  onItemTapped(context, index, tabs, currentIndex),
            )
          : null,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Another screen"),
            ElevatedButton(
              onPressed: () =>
                  context.push(module.externalLinks.home.absolutePath),
              child: const Text('Go home'),
            ),
            ElevatedButton(
              onPressed: () =>
                  context.push(module.externalLinks.linkToModuleB.absolutePath),
              child: const Text('Go to b'),
            ),
            ElevatedButton(
                onPressed: () => GoRouter.of(context)
                    .push(module.internalLinks.details.absolutePath),
                child: const Text("Another Detail"))
          ],
        ),
      ),
    );
  }
}
