import 'dart:async';
import 'package:example/login/auth.view.dart';
import 'package:flutter/material.dart';
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
  GoRouter get router => GoRouter(
      // redirect: redirectOnAuthGuard,
      initialLocation: internalLinks.root.absolutePath,
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
    final user = apiAuth.getUser();
    if (user != null) {
      final sessionOld = DateTime.now().toUtc().isAfter(user.getExpirey());
      final hasNetwork =
          await getDependency<ConnectivityService>().hasNetwork();
      if (sessionOld && hasNetwork) {
        try {
          await apiAuth.cachedLogin();
        } catch (e) {
          await apiAuth.logOutCleanUp();
          return internalLinks.login.absolutePath;
        }
      }
      // user logged in no redirection needed, return null
      return null;
    }
    await apiAuth.logOutCleanUp();
    return internalLinks.login.absolutePath;
  }

  @override
  ExternalModuleLink? get externalLinks => throw UnimplementedError();

  @override
  RootModuleLinks get internalLinks => RootModuleLinks(
      root: ModuleRoutes.fromModuleRouteBase(
        routeBase: RootModuleLinks.staticRoot,
        pageBuilder: ModulePageBuilder(pagebuilder: (context, state) {
          return NoTransitionPage(
              child: HomeScreen(module: this, key: UniqueKey()));
        }),
      ),
      login: ModuleRoutes.fromModuleRouteBase(
          routeBase: RootModuleLinks.staticLogin,
          pageBuilder: ModulePageBuilder(
              builder: ((context, state) => AuthLandingPage(
                  apiService: getDependency<ApiAuthRepository>(),
                  authSuccessRoute: internalLinks.root.absolutePath,
                  module: this)))));
}

class RootModuleLinks extends InternalModuleLink {
  RootModuleLinks({required super.root, required this.login});
  final ModuleRoutes login;

  static ModuleRouteBase staticRoot = const ModuleRouteBase(
      path: "home", completeFragment: "/home", modName: "MainModule");
  static ModuleRouteBase staticLogin = const ModuleRouteBase(
      path: "login", completeFragment: "/login", modName: "MainModule");

  @override
  Map<ModuleRoutes, ModulePageBuilder> get pages {
    final pages = super.pages;
    pages[login] = login.pageBuilder;
    return pages;
  }
}

class HomeScreen extends ModulePage<MainModule> {
  const HomeScreen({super.key, required super.module});

  @override
  Widget build(BuildContext context) {
    final modLinks = module.subModules.map(
      (e) {
        return ElevatedButton(
          onPressed: () => context.go(e.internalLinks.root.absolutePath),
          child: Text('Go to Module ${e.moduleName}'),
        );
      },
    ).toList();

    ApiAuthRepository? apiAuth;
    try {
      apiAuth = module.getDependency<ApiAuthRepository>();
    } catch (e) {}
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            apiAuth != null
                ? ElevatedButton(
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
                  )
                : Container(),
            ...modLinks
          ],
        ),
      ),
    );
  }
}
