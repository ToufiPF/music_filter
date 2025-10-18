import 'package:flutter/material.dart';
import '../data/models/music_folder.dart';
import '../services/music_store_service.dart';
import 'package:provider/provider.dart';

import '../providers/active_tabs.dart';
import '../providers/root_folder.dart';
import '../settings/active_tabs.dart';
import '../settings/settings.dart';
import '../widgets/file_view.dart';
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
    final store = Provider.of<MusicStoreService>(context, listen: false);
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
                    )),
                body: TabBarView(
                  children: [
                    for (var tab in activeTabs.tabs)
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 200),
                        child: _bodyForTab(context, tab, store),
                      )
                  ],
                ),
                bottomSheet: PlayerWidget(),
              ),
            ));
  }

  Widget _bodyForTab(
          BuildContext context, AvailableTab tab, MusicStoreService store) =>
      switch (tab) {
        AvailableTab.folder => StreamBuilder<MusicFolderDto?>(
            stream: store.catalog,
            builder: (context, snapshot) {
              final musicRoot = snapshot.data;
              return Consumer<RootFolderNotifier>(
                  builder: (context, rootPicker, child) {
                if (rootPicker.rootFolder == null) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () => rootPicker.pickFolder(null),
                      child: Text("Chose a folder"),
                    ),
                  );
                } else if (musicRoot == null) {
                  return const Column(children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Scanning for musics..."),
                  ]);
                } else {
                  return FileView(root: musicRoot);
                }
              });
            }),
        AvailableTab.queue => QueueView(),
        AvailableTab.recycleBin => Column(), // RecycleBinView(),
        AvailableTab.settings => SettingsPage(),
      };
}
