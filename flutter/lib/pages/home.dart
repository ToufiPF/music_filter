import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog.dart';
import '../providers/active_tabs.dart';
import '../providers/root_folder.dart';
import '../settings/active_tabs.dart';
import '../settings/settings.dart';
import '../widgets/file_view.dart';
import '../widgets/open_folder_view.dart';
import '../widgets/player_widget.dart';
import '../widgets/queue_view.dart';

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
        builder: (context, activeTabs, child) => DefaultTabController(
              length: activeTabs.tabs.length,
              animationDuration: Duration.zero,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: theme.colorScheme.inversePrimary,
                  toolbarHeight: 0,
                  bottom: TabBar(
                    isScrollable: false,
                    tabs: [
                      for (var tab in activeTabs.tabs)
                        Tab(icon: Icon(tab.iconDefault), text: tab.label)
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    for (var tab in activeTabs.tabs) _bodyForTab(context, tab)
                  ],
                ),
                bottomSheet: PlayerWidget(),
              ),
            ));
  }

  Widget _bodyForTab(BuildContext context, AvailableTab tab) => switch (tab) {
        AvailableTab.folder => Consumer2<RootFolderNotifier, Catalog>(
              builder: (context, rootPicker, musicRoot, child) {
            if (rootPicker.rootFolder == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => rootPicker.pickFolder(null),
                  child: Text("Chose a folder"),
                ),
              );
            } else if (musicRoot.toFilter == null) {
              return const Column(children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Scanning for musics..."),
              ]);
            } else {
              return FileView(root: musicRoot.toFilter!);
            }
          }),
        AvailableTab.queue => QueueView(),
        // Must wrap in builder to re-generate a stream each time this widget is shown,
        // otherwise changing tab disposes of the widget and cancels the stream
        // => bad state stream already listened to
        AvailableTab.openMusics => OpenMusicView(),
        AvailableTab.settings => SettingsPage(),
      };
}
