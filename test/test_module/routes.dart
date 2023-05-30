import 'package:get_it/get_it.dart';
import 'package:open_core/core.dart';

import 'setup.module.dart';

enum TestModRoutes implements ModuleRoutes {
  root(path: "a", completeFragment: "/a"),
  details(path: "details", completeFragment: "/a/details");

  const TestModRoutes({required this.path, required this.completeFragment});

  @override
  final String path;

  @override
  final String completeFragment;

  @override
  String get absolutePath {
    final modName = GetIt.I.get<TestModule>().moduleName;
    return "/$modName$completeFragment";
  }
}
