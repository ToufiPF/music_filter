import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:music_filter/services/music_store_service.dart';
import 'package:music_filter/services/playlist_service.dart';
import 'package:provider/provider.dart';

import '../data/entities/music.dart';
import '../data/models/music_folder.dart';
import '../providers/folders.dart';
import '../util/constants.dart';
import 'context_menu.dart';

class CurrentFolderNotifier extends ChangeNotifier {
  CurrentFolderNotifier(this.current);

  MusicFolderDto current;

  bool get canGoUp => current.parent != null;

  void goTo(MusicFolderDto folder) {
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

  final MusicFolderDto root;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => CurrentFolderNotifier(root),
      child: Consumer<CurrentFolderNotifier>(
        builder: (context, current, child) => PopScope(
            canPop: current.canGoUp,
            onPopInvoked: (didPop) {
              if (didPop) {
                current.goUp();
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

  (List<MusicFolderDto>, List<Music>) _getEntriesToShow(MusicFolderDto current,
      {required bool showHidden, required bool showEmpty}) {
    final folders = current.children.values
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
    List<MusicFolderDto> folders,
    List<Music> musics,
  ) {
    final current = Provider.of<CurrentFolderNotifier>(context, listen: false);
    final playlist = Provider.of<PlaylistService>(context, listen: false);

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: folders.length + musics.length,
        itemBuilder: (context, index) {
          if (index < folders.length) {
            final folder = folders[index];
            return ListTile(
              title: Constants.scrollingText(folder.folderName),
              leading: Icon(Icons.folder_open_outlined),
              trailing: _trailingFolderWidget(context, folder),
              onTap: () => current.goTo(folder),
            );
          } else {
            index -= folders.length;
            final music = musics[index];
            return ListTile(
              title: Constants.scrollingText(music.filename),
              onTap: () async {
                await playlist.appendAll([music]);
              },
              trailing: _trailingFileWidget(context, music),
            );
          }
        });
  }

  Widget _trailingFolderWidget(BuildContext context, MusicFolderDto dir) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconActions.addFolderToPlaylist(context, dir),
          ]);

  Widget _trailingFileWidget(BuildContext context, Music music) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconActions.addMusicToPlaylist(context, music),
          ]);
}
