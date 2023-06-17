import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/active_tabs.dart';
import '../providers/root_folder.dart';
import '../settings/active_tabs.dart';
import '../settings/settings.dart';
import '../widget/file_view.dart';
import 'app_bar.dart';
import 'nav_bar.dart';

/// Home page for the app
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ActiveTabsNotifier>(
        builder: (context, activeTabs, child) => Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.inversePrimary,
              title: Text(activeTabs.selected.appBarTitle ?? MyApp.title),
              actions: [
                AppBarUtils.settingsAction(context),
              ],
            ),
            bottomNavigationBar: MusicNavBar(),
            body: Center(
              child: Consumer<RootFolderNotifier>(
                builder: (context, rootFolder, child) {
                  return rootFolder.rootFolder == null
                      ? ElevatedButton(
                          onPressed: () => rootFolder.pickFolder(null),
                          child: Text("Chose a folder"))
                      : switch (activeTabs.selected) {
                          AvailableTab.queue => Text("Queue view"),
                          AvailableTab.folder =>
                            FileView(root: rootFolder.rootFolder!),
                          AvailableTab.settings => SettingsPage(),
                        };
                },
              ),
            )));
  }
}
