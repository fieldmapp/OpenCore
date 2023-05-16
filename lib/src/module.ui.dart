import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

abstract class ModuleLandingPage extends StatefulWidget {
  final bool hasBottomBar;
  final GetIt locator;

  const ModuleLandingPage(
      {required this.hasBottomBar, super.key, required this.locator});
}

mixin ModuleLandingPageState {
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
