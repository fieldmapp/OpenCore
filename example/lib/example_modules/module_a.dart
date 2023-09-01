import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_core/core.dart';
import 'package:get_it/get_it.dart';

class ModuleA extends AppModule {
  ModuleA() {
    logger.i("Setup $moduleName");
  }

  @override
  RouteBase buildRoutes() {
    // remove default implementation or implement your own RouteBase object here
    return super.buildRoutes();
  }

  @override
  List<ModuleDependency<Object>> get dependencies => [ModuleDependency<ApiAuthRepository>()];

  @override
  String get moduleName => runtimeType.toString();

  @override
  List<ModuleRoutes> get moduleRoutes => ModuleARoutes.values;

  @override
  ModuleRoutes get root => ModuleARoutes.root;

  @override
  RouteBase get routes => buildRoutes();

  @override
  ScaffoldWithNavBarTabItem? get tab => ScaffoldWithNavBarTabItem(
        initialLocation: ModuleARoutes.root.absolutePath,
        icon: const Icon(Icons.home),
        label: 'Section A',
      );

  @override
  Map<ModuleRoutes, ModulePageBuilder> get modulePages {
    final pages = <ModuleRoutes, ModulePageBuilder>{
      ModuleARoutes.root: ModulePageBuilder(pagebuilder: (context, state) {
        return NoTransitionPage(
            child: AnotherScreen(
                module: this,
                key: UniqueKey(),
                hasBottomBar: true,
                locator: GetIt.I));
      }),
      ModuleARoutes.details: ModulePageBuilder(builder: (context, state) {
        return AnotherDetail(module: this, key: UniqueKey());
      })
    };
    return Map.of(pages);
  }
}

enum ModuleARoutes implements ModuleRoutes {
  root(path: "a", completeFragment: "/a"),
  details(path: "details", completeFragment: "/a/details");

  const ModuleARoutes({required this.path, required this.completeFragment});

  @override
  final String path;

  @override
  final String completeFragment;

  @override
  String get absolutePath {
    final modName = GetIt.I.get<AppModule>(instanceName: "ModuleA").moduleName;
    return "/$modName$completeFragment";
  }
}


// Test Pages
class AnotherDetail extends ModulePage<ModuleA> {
  const AnotherDetail({super.key, required super.module});

  @override
  Widget build(BuildContext context) {
    final authApi = module.getDependency<ApiAuthRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Another Detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Another Detail"),
            Text("${authApi.getUser()?.email}"),
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
      {super.key,
      required super.hasBottomBar,
      required super.locator,
      required super.module});

  @override
  Widget build(BuildContext context) {
    final tabs = locator<List<ScaffoldWithNavBarTabItem>>();
    return Scaffold(
      appBar: AppBar(title: const Text('Another Screen')),
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
            const Text("Another screen"),
            ElevatedButton(
              onPressed: () => context.push('/MainModule/home'),
              child: const Text('Go home'),
            ),
            ElevatedButton(
                onPressed: () =>
                    GoRouter.of(context).push(ModuleARoutes.details.absolutePath),
                child: const Text("Another Detail"))
          ],
        ),
      ),
    );
  }
}
