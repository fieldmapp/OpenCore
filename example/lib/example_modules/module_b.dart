import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:open_core/core.dart';

class ModuleB extends AppModule {
  ModuleB({required ModuleBExternalLinks externalModuleLink}) {
    _externalLinks = externalModuleLink;
  }

  @override
  List<ModuleDependency<Object>> get dependencies => [];

  @override
  String get moduleName => runtimeType.toString();

  @override
  ScaffoldWithNavBarTabItem? get tab => ScaffoldWithNavBarTabItem(
        initialLocation: internalLinks.root.absolutePath,
        icon: const Icon(Icons.adb_rounded),
        label: 'Section b',
      );

  late final ModuleBExternalLinks _externalLinks;
  @override
  ModuleBExternalLinks get externalLinks => _externalLinks;

  @override
  ModuleBInternalLinks get internalLinks => ModuleBInternalLinks(
      root: ModuleRoutes.fromModuleRouteBase(
          routeBase: ModuleBInternalLinks.rootStatic,
          pageBuilder: ModulePageBuilder(pagebuilder: (context, state) {
            return NoTransitionPage(
                child: BDetailScreen(
                    module: this, key: UniqueKey(), hasBottomBar: true));
          })));
}

class ModuleBExternalLinks extends ExternalModuleLink {
  ModuleBExternalLinks({required super.home, required this.linkToModuleA});
  final ModuleRouteBase linkToModuleA;
}

class ModuleBInternalLinks extends InternalModuleLink {
  ModuleBInternalLinks({required super.root});

  static ModuleRouteBase rootStatic = const ModuleRouteBase(
      path: "b", completeFragment: "/b", modName: "ModuleB");
}

class BDetailScreen extends ModuleLandingPage<ModuleB> {
  BDetailScreen(
      {super.key, required super.hasBottomBar, required super.module});

  @override
  Widget build(BuildContext context) {
    final tabs = GetIt.I.get<List<ScaffoldWithNavBarTabItem>>();
    final router = GoRouter.of(context);
    final String location = getCurrentLocation(router: router);
    // computes the current index from the current location
    final currentIndex = locationToTabIndex(location, tabs);
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Module B')),
      bottomNavigationBar: hasBottomBar
          ? BottomNavigationBar(
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
            const Text("Detail Mod B"),
            ElevatedButton(
              onPressed: () =>
                  context.push(module.externalLinks.home.absolutePath),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}
