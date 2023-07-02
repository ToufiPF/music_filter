import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music.dart';
import '../providers/folders.dart';
import '../providers/music_hierarchy.dart';
import '../providers/playlist.dart';
import 'context_menu.dart';

class FileView extends StatefulWidget {
  static const tag = "FileView";

  const FileView({super.key, required this.root});

  final MusicFolder root;

  @override
  State<StatefulWidget> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  static const tag = FileView.tag;

  /// Actions that will popup when clicking on the "..." next to a file/folder item
  static const filePopupActions = [
    MenuAction.addToPlaylist,
    MenuAction.export,
    MenuAction.delete,
  ];
  static const dirPopupActions = [
    MenuAction.addToPlaylist,
    MenuAction.export,
    MenuAction.delete,
  ];

  late MusicFolder current;

  /// Whether we can go up in the file hierarchy
  bool get canGoUp => !current.isRoot;

  void goUp() {
    assert(canGoUp, "goUp() called without checking canGoUp");
    setState(() => current = current.parent!);
  }

  @override
  void initState() {
    super.initState();
    current = widget.root;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(onWillPop: () async {
        debugPrint("[$tag] WillPop: $current; ${widget.root}");
        if (canGoUp) {
          goUp();
          return false;
        } else {
          return true;
        }
      }, child: Consumer<MusicHierarchyNotifier>(
          builder: (context, hierarchy, child) {
        final isCurrentFolderOpen = hierarchy.openedFolders.contains(current);
        return Column(
          children: [
            ListTile(
              selected: isCurrentFolderOpen,
              title: Text(current.path),
              leading: IconButton(
                icon: Icon(Icons.drive_folder_upload),
                onPressed: canGoUp ? () => goUp() : null,
              ),
              trailing: _trailingFolderIcon(context, current),
            ),
            Consumer2<ShowHiddenFilesNotifier, ShowEmptyFoldersNotifier>(
                builder: (context, hidden, empty, child) {
              final (folders, musics) = _getEntriesToShow(
                  showHidden: hidden.show, showEmpty: empty.show);

              if (folders.isEmpty && musics.isEmpty) {
                return Text("Empty");
              } else {
                return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                    child: _listView(context, hierarchy, folders, musics));
              }
            }),
          ],
        );
      }));

  (List<MusicFolder>, List<Music>) _getEntriesToShow(
      {required bool showHidden, required bool showEmpty}) {
    final folders = current.folders
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
    MusicHierarchyNotifier hierarchy,
    List<MusicFolder> folders,
    List<Music> musics,
  ) {
    final isCurrentFolderOpen = hierarchy.openedFolders.contains(current);
    return ListView.builder(
        itemCount: folders.length + musics.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index < folders.length) {
            final folder = folders[index];
            final isFolderOpen = hierarchy.openedFolders.contains(folder);
            return ListTile(
              selected: isFolderOpen,
              title: Text(folder.folderName),
              leading: Icon(Icons.folder_outlined),
              trailing: _trailingFolderIcon(context, folder),
              onTap: () => setState(() => current = folder),
            );
          } else {
            index -= folders.length;
            final music = musics[index];
            return ListTile(
              selected: isCurrentFolderOpen,
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
    final folderStore =
        Provider.of<MusicHierarchyNotifier>(context, listen: false);

    switch (action) {
      case MenuAction.addToPlaylist:
        final musics = e.allDescendants;
        debugPrint("[$tag] Adding $musics to playlist");
        await playlist.appendAll(musics);
        await folderStore.openFolder(e, recursive: true);
        break;
      case MenuAction.delete:
        break;
      default:
        throw StateError("Clicked on unsupported menu item $action");
    }
  }

  Future<void> _onMusicPopupMenuAction(
      BuildContext context, MenuAction action, Music e) async {
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
    final folderStore =
        Provider.of<MusicHierarchyNotifier>(context, listen: false);

    switch (action) {
      case MenuAction.addToPlaylist:
        final musics = [e];
        debugPrint("[$tag] Adding $musics to playlist");
        await playlist.appendAll(musics);
        await folderStore.openFolder(current, recursive: false);
        break;
      case MenuAction.delete:
        break;
      default:
        throw StateError("Clicked on unsupported menu item $action");
    }
  }
}
