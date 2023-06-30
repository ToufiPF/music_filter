import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music.dart';
import '../models/store.dart';
import '../providers/active_tabs.dart';
import '../providers/root_folder.dart';
import '../settings/active_tabs.dart';
import '../settings/settings.dart';
import '../widget/file_view.dart';
import '../widget/music_list_view.dart';
import '../widget/player_widget.dart';
import '../widget/queue_view.dart';

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
                  flexibleSpace: SafeArea(
                    child: TabBar(tabs: [
                      for (var tab in activeTabs.tabs)
                        Tab(icon: Icon(tab.iconDefault), text: tab.label)
                    ]),
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

  Widget _bodyForTab(BuildContext context, AvailableTab tab) {
    final store = Provider.of<Store>(context, listen: false);

    return switch (tab) {
      AvailableTab.folder => Consumer<RootFolderNotifier>(
          builder: (context, rootFolder, child) => rootFolder.rootFolder == null
              ? Center(
                  child: ElevatedButton(
                  onPressed: () => rootFolder.pickFolder(null),
                  child: Text("Chose a folder"),
                ))
              : FileView(root: rootFolder.rootFolder!)),
      AvailableTab.queue => QueueView(),
      AvailableTab.keptMusics => StreamBuilder<List<Music>>(
          initialData: [],
          stream: store.musicsForState(KeepState.kept),
          builder: (context, snapshot) => MusicListView(
            musics: snapshot.data!,
            popupActions: [],
            onSelected: (context, musicIdx, action) {},
          ),
        ),
      AvailableTab.deletedMusics => StreamBuilder<List<Music>>(
          initialData: [],
          stream: store.musicsForState(KeepState.deleted),
          builder: (context, snapshot) => MusicListView(
            musics: snapshot.data!,
            popupActions: [],
            onSelected: (context, musicIdx, action) {},
          ),
        ),
      AvailableTab.settings => SettingsPage(),
    };
  }
}
