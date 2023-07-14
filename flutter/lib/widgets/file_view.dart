import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music.dart';
import '../models/music_folder.dart';
import '../models/state_store.dart';
import '../providers/folders.dart';
import '../providers/playlist.dart';
import 'context_menu.dart';

class CurrentFolderNotifier extends ChangeNotifier {
  CurrentFolderNotifier(this.current);

  MusicFolder current;

  bool get canGoUp => current.parent != null;

  void goTo(MusicFolder folder) {
    current = folder;
    notifyListeners();
  }

  void goUp() {
    current = current.parent!;
    notifyListeners();
  }
}

class FileView extends StatelessWidget {
  static const tag = "FileView";

  /// Actions that will popup when clicking on the "..." next to a file/folder item
  static const filePopupActions = [
    MenuAction.startFiltering,
    MenuAction.export,
    MenuAction.delete,
  ];
  static const dirPopupActions = [
    MenuAction.startFiltering,
    MenuAction.export,
    MenuAction.delete,
  ];

  const FileView({super.key, required this.root});

  final MusicFolder root;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => CurrentFolderNotifier(root),
      child: Consumer<CurrentFolderNotifier>(
        builder: (context, current, child) => WillPopScope(
            onWillPop: () async {
              if (current.canGoUp) {
                current.goUp();
                return false;
              } else {
                return true;
              }
            },
            child: Column(
              children: [
                ListTile(
                  title: Text(current.current.path),
                  leading: IconButton(
                    icon: Icon(Icons.drive_folder_upload),
                    onPressed: current.canGoUp ? current.goUp : null,
                  ),
                  trailing: _trailingFolderIcon(context, current.current),
                ),
                Consumer2<ShowHiddenFilesNotifier, ShowEmptyFoldersNotifier>(
                    builder: (context, hidden, empty, child) {
                  final (folders, musics) = _getEntriesToShow(current.current,
                      showHidden: hidden.show, showEmpty: empty.show);

                  debugPrint("[$tag]: build: $current");
                  if (folders.isEmpty && musics.isEmpty) {
                    return Text("Empty");
                  } else {
                    return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                        child: _listView(context, folders, musics));
                  }
                }),
              ],
            )),
      ));

  (List<MusicFolder>, List<Music>) _getEntriesToShow(MusicFolder current,
      {required bool showHidden, required bool showEmpty}) {
    final folders = current.children
        .where((e) => showHidden || !e.folderName.startsWith('.'))
        .where((e) => showEmpty || e.allDescendants.isNotEmpty)
        .sortedBy((e) => e.path);
    final musics = current.musics
        .where((e) => showHidden || !e.filename.startsWith('.'))
        .sortedBy((e) => e.path);
    return (folders, musics);
  }

  Widget _listView(
    BuildContext context,
    List<MusicFolder> folders,
    List<Music> musics,
  ) {
    final current = Provider.of<CurrentFolderNotifier>(context, listen: false);
    return ListView.builder(
        itemCount: folders.length + musics.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index < folders.length) {
            final folder = folders[index];
            return ListTile(
              title: Text(folder.folderName),
              leading: Icon(Icons.folder_outlined),
              trailing: _trailingFolderIcon(context, folder),
              onTap: () => current.goTo(folder),
            );
          } else {
            index -= folders.length;
            final music = musics[index];
            return ListTile(
              title: Text(music.filename),
              onTap: null,
              trailing: PopupMenuButton<int>(
                itemBuilder: (context) => [
                  for (var action in filePopupActions)
                    PopupMenuItem<int>(
                        value: action.index, child: Text(action.text)),
                ],
                child: Icon(Icons.more_vert, size: 32),
                onSelected: (index) => _onMusicPopupMenuAction(
                    context, MenuAction.values[index], music),
              ),
            );
          }
        });
  }

  Widget _trailingFolderIcon(BuildContext context, MusicFolder dir) =>
      PopupMenuButton<int>(
        itemBuilder: (context) => [
          for (var action in dirPopupActions)
            PopupMenuItem<int>(value: action.index, child: Text(action.text)),
        ],
        child: Icon(Icons.more_vert, size: 32),
        onSelected: (index) =>
            _onFolderPopupMenuAction(context, MenuAction.values[index], dir),
      );

  Future<void> _onFolderPopupMenuAction(
      BuildContext context, MenuAction action, MusicFolder e) async {
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
    final store = Provider.of<StateStore>(context, listen: false);

    switch (action) {
      case MenuAction.startFiltering:
        final musics = e.allDescendants;
        debugPrint("[$tag] Adding $musics to playlist");
        await playlist.appendAll(musics);
        await store.startTracking(e, e.allDescendants);
        break;
      case MenuAction.delete:
        break;
      default:
        throw StateError("Clicked on unsupported menu item $action");
    }
  }

  Future<void> _onMusicPopupMenuAction(
      BuildContext context, MenuAction action, Music e) async {
    final current = Provider.of<CurrentFolderNotifier>(context, listen: false);
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
    final store = Provider.of<StateStore>(context, listen: false);

    switch (action) {
      case MenuAction.startFiltering:
        final musics = [e];
        debugPrint("[$tag] Adding $musics to playlist");
        await playlist.appendAll(musics);
        await store.startTracking(current.current, musics);
        break;
      case MenuAction.delete:
        break;
      default:
        throw StateError("Clicked on unsupported menu item $action");
    }
  }
}
