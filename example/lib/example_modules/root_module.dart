import 'dart:async';

import 'package:example/login/auth.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:open_core/core.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class MainModule extends RootModule {
  MainModule({required super.subModules, required super.dependencies});

  static Future<RootModule> fromConfig(
      {required List<AppModule> subModules,
      required List<ModuleDependency> dependencies}) async {
    final mod = MainModule(subModules: subModules, dependencies: dependencies);
    await mod.init<MainModule>();
    return mod;
  }

  @override
  String get moduleName => runtimeType.toString();

  @override
  Map<ModuleRoutes, ModulePageBuilder> get modulePages {
    final pages = <ModuleRoutes, ModulePageBuilder>{
      RootRoutes.root: ModulePageBuilder(pagebuilder: (context, state) {
        return NoTransitionPage(
            child: HomeScreen(module: this, key: UniqueKey()));
      }),
      RootRoutes.login: ModulePageBuilder(
          builder: ((context, state) => AuthLandingPage(
              apiService: getDependency<ApiAuthRepository>(),
              authSuccessRoute: RootRoutes.root.absolutePath,
              module: this)))
    };
    return Map.of(pages);
  }

  @override
  List<ModuleRoutes> get moduleRoutes => RootRoutes.values;

  @override
  ModuleRoutes get root => RootRoutes.root;

  @override
  GoRouter get router => GoRouter(
      redirect: redirectOnAuthGuard,
      initialLocation: RootRoutes.root.absolutePath,
      navigatorKey: _rootNavigatorKey,
      routes: [routes]);

  @override
  RouteBase get routes => buildRoutes();

  // we do not want to have navbaritm atm
  @override
  ScaffoldWithNavBarTabItem? get tab => null;

  /// checks auth for every route change, if the user object is null the app
  /// redirects to the login page.
  ///
  /// Case 1: Offline
  /// if offline, continue using the currently available User object. Logout is
  /// still possible, but you will not be able to login offline
  /// Case 2: Online
  /// if online and the session is still valid continue using the currently
  /// available User object, nothing changes.
  /// if online and the session is old try to relogin the current user with the
  /// cached login data see [ApiRepositoryService.cachedLogin]
  FutureOr<String?> redirectOnAuthGuard(
      BuildContext context, GoRouterState state) async {
    final apiAuth = getDependency<ApiAuthRepository>();
    final user =apiAuth.getUser();
    if (user != null) {
      final sessionOld = DateTime.now().toUtc().isAfter(user.getExpirey());
      final hasNetwork = await getDependency<ConnectivityService>().hasNetwork();
      if (sessionOld && hasNetwork) {
        try {
          await apiAuth.cachedLogin();
        } catch (e) {
          await apiAuth.logOutCleanUp();
          return RootRoutes.login.absolutePath;
        }
      }
      // user logged in no redirection needed, return null
      return null;
    }
    await apiAuth.logOutCleanUp();
    return RootRoutes.login.absolutePath;
  }

}

enum RootRoutes implements ModuleRoutes {
  root(path: "/home", completeFragment: "/home"),
  login(path: "/login", completeFragment: "/login");

  const RootRoutes({required this.path, required this.completeFragment});

  @override
  final String path;

  @override
  final String completeFragment;

  @override
  String get absolutePath {
    final modName =
        GetIt.I.get<MainModule>(instanceName: "MainModule").moduleName;
    return "/$modName$completeFragment";
  }
}

class HomeScreen extends ModulePage<MainModule> {
  const HomeScreen({super.key, required super.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final apiAuth = module.getDependency<ApiAuthRepository>();
                await apiAuth.logout(onLogout: () {
                  // remove user data/cache on log out
                  GetIt.I.get<ApiDataRepository>().emptyCache(
                        () async {},
                      );
                  GetIt.I.get<ApiMediaRepository>().emptyCache(
                        () async {},
                      );
                  GoRouter.of(context).refresh();
                });
              },
              child: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () => context
                  .go(module.subModules.first.moduleRoutes.first.absolutePath),
              child: const Text('Go to Module A'),
            ),
            ElevatedButton(
              onPressed: () => context.go(module.subModules.last.moduleRoutes.first.absolutePath),
              child: const Text('Go to Module B'),
            ),
          ],
        ),
      ),
    );
  }
}
