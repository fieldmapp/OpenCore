import 'package:open_core/core.dart';

const modName = "Test";

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
    return "/$modName$completeFragment";
  }
}
