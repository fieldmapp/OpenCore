part of core;

abstract class ModulePage<T extends AppModule> extends StatelessWidget {
  final T module;

  const ModulePage({super.key, required this.module});
}

class ModulePageBuilder {
  ModulePage Function(BuildContext context, GoRouterState state)? builder;
  Page<ModulePage> Function(BuildContext context, GoRouterState state)?
      pagebuilder;

  ModulePageBuilder({this.builder, this.pagebuilder}) {
    // throw an Exception if neither is set
    if (builder == null && pagebuilder == null) {
      throw ModuleException(
          cause:
              "ModulePageBuilder cant be constructed without an implementation of Builder or PageBuilder!",
          type: ModuleExceptionType.initialization);
    }
  }
}

/// TODO: Add BottomBar to this widget
abstract class ModuleLandingPage<T extends AppModule> extends ModulePage<T>
    with ModuleLandingPageUtil {
  final bool hasBottomBar;

  ModuleLandingPage(
      {super.key, required this.hasBottomBar, required super.module});
}

mixin ModuleLandingPageUtil {
  // getter that computes the current index from the current location,
  // using the helper method below
  int locationToTabIndex(
      String location, List<ScaffoldWithNavBarTabItem> tabs) {
    final index =
        tabs.indexWhere((t) => location.startsWith(t.initialLocation));
    // if index not found (-1), return 0
    return index < 0 ? 0 : index;
  }

  // callback used to navigate to the desired tab
  void onItemTapped(BuildContext context, int tabIndex,
      List<ScaffoldWithNavBarTabItem> tabs, int currentIndex) {
    if (tabIndex != currentIndex) {
      // go to the initial location of the selected tab (by index)
      context.go(tabs[tabIndex].initialLocation);
    }
  }

  BottomNavigationBar? getBottomNavBar(int currentIndex,
      List<ScaffoldWithNavBarTabItem> tabs, BuildContext context) {
    return tabs.length > 1
        ? BottomNavigationBar(
            currentIndex: currentIndex,
            items: tabs,
            onTap: (index) => onItemTapped(context, index, tabs, currentIndex))
        : null;
  }
}

class ScaffoldWithNavBarTabItem extends BottomNavigationBarItem {
  const ScaffoldWithNavBarTabItem(
      {required this.initialLocation, required Widget icon, String? label})
      : super(icon: icon, label: label);

  /// The initial location/path
  final String initialLocation;
}
