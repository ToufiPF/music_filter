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
                  trailing: _trailingFolderWidget(context, current.current),
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
    final store = Provider.of<StateStore>(context, listen: false);
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: folders.length + musics.length,
        itemBuilder: (context, index) {
          if (index < folders.length) {
            final folder = folders[index];
            return ListTile(
              title: Text(folder.folderName),
              leading: Selector<StateStore, bool>(
                selector: (context, store) => store.isTrackedFolder(folder),
                builder: (context, isTracked, child) => isTracked
                    ? Icon(Icons.folder_open_outlined)
                    : Icon(Icons.folder_outlined),
              ),
              trailing: _trailingFolderWidget(context, folder),
              onTap: () => current.goTo(folder),
            );
          } else {
            index -= folders.length;
            final music = musics[index];
            return ListTile(
              title: Text(music.filename),
              onTap: () async {
                await playlist.appendAll([music]);
                await store.startTracking([music]);
              },
              trailing: _trailingFileWidget(context, music),
            );
          }
        });
  }

  Widget _trailingFolderWidget(BuildContext context, MusicFolder dir) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconActions.trackOrExportFolder(context, dir),
          ]);

  Widget _trailingFileWidget(BuildContext context, Music music) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconActions.trackOrExportMusic(context, music),
          ]);
}
