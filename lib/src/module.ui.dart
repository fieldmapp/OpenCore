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

  String getCurrentLocation({required GoRouter router}) {
    final RouteMatch lastMatch =
        router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  Widget getBottomNav(List<ScaffoldWithNavBarTabItem> tabs, int currentIndex) {
    return Builder(builder: (context) {
      return BottomNavigationBar(
        enableFeedback: true,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).primaryColorDark,
        unselectedLabelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
        landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
        onTap: (index) => onItemTapped(context, index, tabs, currentIndex),
        items: tabs,
        currentIndex: currentIndex,
      );
    });
  }
}

class ScaffoldWithNavBarTabItem extends BottomNavigationBarItem {
  const ScaffoldWithNavBarTabItem(
      {required this.initialLocation,
      required super.icon,
      super.label,
      super.backgroundColor});

  /// The initial location/path
  final String initialLocation;
}
