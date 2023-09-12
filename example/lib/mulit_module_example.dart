import 'package:example/app_constants.dart';
import 'package:example/example_modules/module_a.dart';
import 'package:example/example_modules/module_b.dart';
import 'package:example/example_modules/root_module.dart';
import 'package:flutter/material.dart';
import 'package:open_core/core.dart';

Future<RootModule> setupMultiModuleEx() async {
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
  // final modA = ModuleA();
  // final modB = ModuleB();
  final RootModule mainMod = await MainModule.fromConfig(dependencies: [
    // // GLOBAL scaffold key
    ModuleDependency<GlobalKey<ScaffoldMessengerState>>(toInject: scaffoldKey),
    // // services
    ModuleDependency<ApiAuthRepository>(toInject: apiAuthRepository),
    // ModuleDependency<ApiDataRepository>(toInject: apiDataRepository),
    // ModuleDependency<ApiMediaRepository>(toInject: apiMediaRepository),
    ModuleDependency<ConnectivityService>(toInject: connectionService),
  ], subModules: [
    ModuleA(
        externalModuleLink: ModuleAExternalLinks(
            home: RootModuleLinks.staticRoot,
            linkToModuleB: ModuleBInternalLinks.rootStatic)),
    ModuleB(
        externalModuleLink: ModuleBExternalLinks(
            home: RootModuleLinks.staticRoot,
            linkToModuleA: ModuleAInternalLinks.staticRoot))
  ]);

  return mainMod;
}
