import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:open_core/core.dart';

class ModuleB extends AppModule {
  @override
  List<ModuleDependency<Object>> get dependencies => [];

  @override
  String get moduleName => runtimeType.toString();

  @override
  Map<ModuleRoutes, ModulePageBuilder> get modulePages {
    final pages = <ModuleRoutes, ModulePageBuilder>{
      ModuleBRoutes.root: ModulePageBuilder(pagebuilder: (context, state) {
        return NoTransitionPage(
            child: BDetailScreen(
                module: this,
                key: UniqueKey(),
                hasBottomBar: true,
                locator: GetIt.I));
      })
    };
    return Map.of(pages);
  }

  @override
  List<ModuleRoutes> get moduleRoutes => ModuleBRoutes.values;

  @override
  ModuleRoutes get root => ModuleBRoutes.root;

  @override
  RouteBase get routes => buildRoutes();

  @override
  ScaffoldWithNavBarTabItem? get tab => ScaffoldWithNavBarTabItem(
        initialLocation: ModuleBRoutes.root.absolutePath,
        icon: const Icon(Icons.adb_rounded),
        label: 'Section b',
      );
}

enum ModuleBRoutes implements ModuleRoutes {
  root(path: "b", completeFragment: "/b"),
  details(path: "details", completeFragment: "/b/details");

  const ModuleBRoutes({required this.path, required this.completeFragment});

  @override
  final String path;

  @override
  final String completeFragment;

  @override
  String get absolutePath {
    final modName = GetIt.I.get<AppModule>(instanceName: "ModuleB").moduleName;
    return "/$modName$completeFragment";
  }
}

class BDetailScreen extends ModuleLandingPage<ModuleB> {
  BDetailScreen(
      {super.key,
      required super.hasBottomBar,
      required super.locator,
      required super.module});
  
  @override
  Widget build(BuildContext context) {
    final tabs = locator<List<ScaffoldWithNavBarTabItem>>();
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Module B')),
      bottomNavigationBar: hasBottomBar
          ? super.getBottomNavBar(
              // computes the current index from the current location
              locationToTabIndex(GoRouter.of(context).location, tabs),
              tabs,
              context)
          : null,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Detail Mod B"),
            ElevatedButton(
              onPressed: () => context.push('/home'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}
