import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../models/music.dart';
import '../models/store.dart';
import '../providers/folders.dart';
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
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        debugPrint("[$tag] WillPop: $current; ${widget.root}");
        if (canGoUp) {
          goUp();
          return false;
        } else {
          return true;
        }
      },
      child: Column(
        children: [
          ListTile(
            title: Text(current.path),
            leading: IconButton(
              icon: Icon(Icons.drive_folder_upload),
              onPressed: canGoUp ? () => goUp() : null,
            ),
            trailing: _trailingFolderIcon(context, current),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
              child:
                  Consumer2<ShowHiddenFilesNotifier, ShowEmptyFoldersNotifier>(
                      builder: (context, hidden, empty, child) {
                var children = _loadChildren(context,
                    showEmpty: empty.show, showHidden: hidden.show);
                if (children.isEmpty) {
                  return Text("Empty");
                } else {
                  return ListView(
                    shrinkWrap: true,
                    children: children,
                  );
                }
              })),
        ],
      ));

  List<Widget> _loadChildren(BuildContext context,
      {required bool showHidden, required bool showEmpty}) {
    // skip hidden files ?
    final files = current.musics
        .where((e) => showHidden || !p.basename(e.path).startsWith('.'))
        .sortedBy((e) => e.path);
    final directories = current.folders
        .where((e) => showHidden || !p.basename(e.path).startsWith('.'))
        .sortedBy((e) => e.path);

    final children = <Widget>[];
    for (var dir in directories) {
      // skip empty folders ?
      if (!showEmpty && dir.allDescendants.isEmpty) {
        continue;
      }

      children.add(ListTile(
        title: Text(p.basename(dir.path)),
        leading: Icon(Icons.folder_outlined),
        trailing: _trailingFolderIcon(context, dir),
        onTap: () => setState(() => current = dir),
      ));
    }

    children.addAll(files.map((e) => ListTile(
          title: Text(p.basename(e.path)),
          onTap: null,
          trailing: PopupMenuButton<int>(
            itemBuilder: (context) => [
              for (var action in filePopupActions)
                PopupMenuItem<int>(
                    value: action.index, child: Text(action.text)),
            ],
            child: Icon(Icons.more_vert, size: 32),
            onSelected: (index) =>
                _onMusicPopupMenuAction(context, MenuAction.values[index], e),
          ),
        )));

    return children;
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
    final store = Provider.of<Store>(context, listen: false);

    switch (action) {
      case MenuAction.addToPlaylist:
        final musics = e.allDescendants;
        debugPrint("[$tag] Adding $musics to playlist");
        await playlist.appendAll(musics);
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
    final store = Provider.of<Store>(context, listen: false);

    switch (action) {
      case MenuAction.addToPlaylist:
        final musics = [e];
        debugPrint("[$tag] Adding $musics to playlist");
        await playlist.appendAll(musics);
        break;
      case MenuAction.delete:
        break;
      default:
        throw StateError("Clicked on unsupported menu item $action");
    }
  }
}
