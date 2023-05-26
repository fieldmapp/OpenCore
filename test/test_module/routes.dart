import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:open_core/core.dart';

import 'setup.module.dart';

@protected
RouteBase buildRoutes(GetIt locator) {
  return GoRoute(
    path: '/${Routes.root.path}',
    pageBuilder: (context, state) =>
        const NoTransitionPage(child: Placeholder()),
    routes: [
      GoRoute(
        path: Routes.details.path,
        builder: (context, state) => const Placeholder(),
      ),
    ],
  );
}

enum Routes implements ModuleRoutes {
  root(parentModule: "test", path: "a", absolutePath: "/a"),
  details(parentModule: "test", path: "details", absolutePath: "/a/details");

  const Routes(
      {required this.parentModule,
      required this.path,
      required this.absolutePath});

  @override
  final String path;

  @override
  final String absolutePath;

  @override
  final String parentModule;
}
