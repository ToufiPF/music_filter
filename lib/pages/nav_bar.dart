import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/active_tabs.dart';

class MusicNavBar extends StatelessWidget {
  const MusicNavBar({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ActiveTabsNotifier>(
      builder: (context, activeTabs, child) => NavigationBar(
              selectedIndex: activeTabs.activeIndex,
              onDestinationSelected: (selected) =>
                  activeTabs.activeIndex = selected,
              destinations: <NavigationDestination>[
                for (var tab in activeTabs.activeTabs)
                  NavigationDestination(
                    icon: Icon(tab.iconDefault),
                    selectedIcon: Icon(tab.iconSelected),
                    label: tab.label,
                  )
              ]));
}
