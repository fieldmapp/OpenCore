
import 'package:example/app_constants.dart';
import 'package:example/example_modules/module_a.dart';
import 'package:example/example_modules/module_b.dart';
import 'package:example/example_modules/root_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:open_core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FlutterCryptography.enable();

  final appwrite = AppwriteBase(
      endpoint: AppConstant().endpoint,
      projectId: AppConstant().projectId,
      selfSigned: AppConstant().selfSigned);

  final ApiAuthRepository apiAuthRepository =
      AppwriteAuthRepository(account: appwrite.account);
  await apiAuthRepository.init();

  // final ApiDataRepository apiDataRepository = AppwriteDataRepository(
  //     database: appwrite.database,
  //     collections: AppConstant().collections,
  //     databaseId: AppConstant().databaseId);
  // await apiDataRepository.init();

  // final ApiMediaRepository apiMediaRepository = AppwriteMediaRepository(
  //     storage: appwrite.storage, buckets: AppConstant().buckets);
  // await apiMediaRepository.init();

  // // scaffold key to be injected
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  final connectionService =
      ConnectivityService(connectedServices: [AppConstant().endpoint]);

  // listen to connectivity changes globally and indicate changes
  connectionService.indicateConnectionChanges(scaffoldKey: scaffoldKey);


  await MainModule.fromConfig(dependencies: [
    // // GLOBAL scaffold key
    ModuleDependency<GlobalKey<ScaffoldMessengerState>>(toInject: scaffoldKey),
    // // services
    ModuleDependency<ApiAuthRepository>(toInject: apiAuthRepository),
    // ModuleDependency<ApiDataRepository>(toInject: apiDataRepository),
    // ModuleDependency<ApiMediaRepository>(toInject: apiMediaRepository),
    ModuleDependency<ConnectivityService>(toInject: connectionService),
  ], subModules: [
    ModuleA(),
    ModuleB()
  ]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      scaffoldMessengerKey: GetIt.I.get<GlobalKey<ScaffoldMessengerState>>(),
      routerConfig: GetIt.I.get<MainModule>(instanceName: "MainModule").router,
    );
  }
}