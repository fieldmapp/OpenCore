import 'package:example/example_modules/module_data/screens/data_doc_view.dart';
import 'package:example/example_modules/module_data/screens/data_list_view.dart';
import 'package:example/example_modules/module_data/screens/doc_list.dart';
import 'package:example/example_modules/module_data/screens/storage_list.dart';
import 'package:flutter/material.dart';
import 'package:open_core/core.dart';
import 'package:go_router/go_router.dart';

class DataModule extends AppModule {
  final List<String> collections;
  final List<String> buckets;

  DataModule(
      {super.externalModuleLink,
      required this.collections,
      required this.buckets});

  @override
  List<ModuleDependency<Object>> get dependencies => [
        ModuleDependency<ApiDataRepository>(),
        ModuleDependency<ApiMediaRepository>(),
        ModuleDependency<ConnectivityService>()
      ];

  @override
  ExternalModuleLink? get externalLinks => null;

  @override
  DataModuleInternalLinks get internalLinks => DataModuleInternalLinks(
      root: ModuleRoutes(
          pageBuilder: ModulePageBuilder(
              pagebuilder: (context, state) => NoTransitionPage(
                      child: DataListView(
                    module: this,
                    hasBottomBar: true,
                  ))),
          path: "list",
          completeFragment: "/list",
          modName: moduleName),
      collection: ModuleRoutes.fromModuleRouteBase(
          routeBase: DataModuleInternalLinks.collectionStatic,
          pageBuilder: ModulePageBuilder(
              builder: (context, state) =>
                  DocList(module: this, id: state.pathParameters['id']!))),
      bucket: ModuleRoutes.fromModuleRouteBase(
          routeBase: DataModuleInternalLinks.bucketStatic,
          pageBuilder: ModulePageBuilder(
              builder: (context, state) =>
                  StorageList(module: this, id: state.pathParameters['id']!))),
      doc: ModuleRoutes.fromModuleRouteBase(
          routeBase: DataModuleInternalLinks.docStatic,
          pageBuilder: ModulePageBuilder(
            pagebuilder: (context, state) => NoTransitionPage(
              child: DataDocView(
                  module: this,
                  docID: state.pathParameters['docid']!,
                  collectionID: state.pathParameters['collectionid']!,
                  revision: state.pathParameters['revision']),
            ),
          )));

  @override
  String get moduleName => runtimeType.toString();

  @override
  ScaffoldWithNavBarTabItem? get tab => ScaffoldWithNavBarTabItem(
        initialLocation: internalLinks.root.absolutePath,
        icon: const Icon(Icons.dashboard_customize_sharp),
        label: 'Data',
      );
}

class DataModuleInternalLinks extends InternalModuleLink {
  DataModuleInternalLinks(
      {required this.collection,
      required this.bucket,
      required this.doc,
      required super.root});
  static String modName = "DataModule";
  static ModuleRouteBase collectionStatic = ModuleRouteBase(
      path: "collection/:id",
      completeFragment: "/list/collection",
      modName: modName);
  final ModuleRoutes collection;

  static ModuleRouteBase bucketStatic = ModuleRouteBase(
      path: "bucket/:id", completeFragment: "/list/bucket", modName: modName);
  final ModuleRoutes bucket;

  static ModuleRouteBase docStatic = ModuleRouteBase(
      path: "doc/:collectionid/:docid/:revision",
      completeFragment: "/list/doc",
      modName: modName);
  final ModuleRoutes doc;

  @override
  Map<ModuleRoutes, ModulePageBuilder> get pages {
    final pages = super.pages;
    pages[collection] = collection.pageBuilder;
    pages[bucket] = bucket.pageBuilder;
    pages[doc] = doc.pageBuilder;
    return pages;
  }
}
