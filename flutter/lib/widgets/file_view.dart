import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music.dart';
import '../models/music_folder.dart';
import '../models/state_store.dart';
import '../providers/folders.dart';
import '../providers/playlist.dart';

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
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: folders.length + musics.length,
        itemBuilder: (context, index) {
          if (index < folders.length) {
            final folder = folders[index];
            return ListTile(
              title: Text(folder.folderName),
              leading: IconButton(
                  icon: Icon(Icons.rule_folder_rounded),
                  onPressed: () =>
                      _startFiltering(context, folder.allDescendants)),
              trailing: _trailingFolderWidget(context, folder),
              onTap: () => current.goTo(folder),
            );
          } else {
            index -= folders.length;
            final music = musics[index];
            return ListTile(
              title: Text(music.filename),
              leading: Icon(Icons.playlist_add),
              onTap: () => _startFiltering(context, [music]),
              trailing: _trailingFileWidget(context, music),
            );
          }
        });
  }

  Widget _trailingFolderWidget(BuildContext context, MusicFolder dir) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () => _export(context, dir.allDescendants),
              icon: Icon(Icons.done_all)),
        ],
      );

  Widget _trailingFileWidget(BuildContext context, Music music) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () => _export(context, [music]),
              icon: Icon(Icons.done)),
        ],
      );

  Future<void> _startFiltering(BuildContext context, List<Music> musics) async {
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
    final store = Provider.of<StateStore>(context, listen: false);
    debugPrint("[$tag]_startFiltering($musics)");
    await playlist.appendAll(musics);
    await store.startTracking(musics);
  }

  Future<void> _export(BuildContext context, List<Music> musics) async {
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
    final store = Provider.of<StateStore>(context, listen: false);
    debugPrint("[$tag]_export($musics)");
    await playlist.removeAll(musics);
    await store.exportState(musics);
  }
}
