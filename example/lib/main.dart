import 'package:example/data_module_example.dart';
import 'package:example/mulit_module_example.dart';
import 'package:example/simple_module_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final exampleModule = await setupMultiModuleEx();
  final exampleModule = await setupDataModule();
  // final exampleModule = await setupSimpleModule();
  runApp(ProviderScope(
      child: MainApp(
    router: exampleModule.router,
    scaffoldState:
        exampleModule.getDependency<GlobalKey<ScaffoldMessengerState>>(),
  )));
}

class MainApp extends StatelessWidget {
  final GoRouter router;
  final GlobalKey<ScaffoldMessengerState> scaffoldState;
  const MainApp({Key? key, required this.router, required this.scaffoldState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      scaffoldMessengerKey: scaffoldState,
      routerConfig: router,
    );
  }
}
