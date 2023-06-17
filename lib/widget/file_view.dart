import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../models/music.dart';
import '../providers/playlist.dart';
import 'context_menu.dart';

class FileView extends StatefulWidget {
  static const tag = "FileView";

  const FileView({super.key, required this.root});

  final Directory root;

  @override
  State<StatefulWidget> createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  static const tag = FileView.tag;

  /// Actions that will popup when clicking on the "..." next to a file/folder item
  static const filePopupActions = [MenuAction.addToPlaylist, MenuAction.delete];
  static const dirPopupActions = [MenuAction.addToPlaylist, MenuAction.delete];

  late Directory current;

  /// Whether we can go up in the file hierarchy
  bool get canGoUp => widget.root.path != current.path;

  void goUp() {
    assert(canGoUp, "goUp() called without checking canGoUp");
    setState(() => current = current.parent);
  }

  @override
  void initState() {
    super.initState();
    current = widget.root;
  }

  @override
  void dispose() {
    super.dispose();
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
              child: FutureBuilder<List<Widget>>(
                  future: _loadChildren(context),
                  builder: (context, snapshot) {
                    var children = snapshot.data;
                    if (children == null) {
                      return CircularProgressIndicator();
                    } else if (children.isEmpty) {
                      return Text("Empty");
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        children: children,
                      );
                    }
                  }),
            ),
          ],
        ),
      );

  Future<List<Widget>> _loadChildren(BuildContext context) async {
    final entries = await current.list().toList();
    final files = entries.whereType<File>().sortedBy((e) => e.path);
    final directories = entries.whereType<Directory>().sortedBy((e) => e.path);

    final children = <Widget>[];
    children.addAll(directories.map((dir) => ListTile(
          title: Text(p.basename(dir.path)),
          leading: Icon(Icons.folder_outlined),
          onTap: () => setState(() => current = dir),
          trailing: PopupMenuButton<int>(
            itemBuilder: (context) => [
              for (var action in dirPopupActions)
                PopupMenuItem<int>(
                    value: action.index, child: Text(action.text)),
            ],
            child: Icon(Icons.more_vert, size: 32),
            onSelected: (index) =>
                _onPopupMenuAction(context, MenuAction.values[index], dir),
          ),
        )));

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
                _onPopupMenuAction(context, MenuAction.values[index], e),
          ),
        )));

    return children;
  }

  Future<void> _onPopupMenuAction(
      BuildContext context, MenuAction action, FileSystemEntity entity) async {
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);

    switch (action) {
      case MenuAction.addToPlaylist:
        final musics = await _fetchMusicsIn(entity, recursive: true);
        debugPrint("[$tag] Adding $musics to playlist");
        playlist.appendAll(musics);
        break;
      case MenuAction.delete:
        break;
      default:
        throw StateError("Clicked on unsupported menu item $action");
    }
  }

  Future<List<Music>> _fetchMusicsIn(FileSystemEntity e,
      {bool recursive = true}) async {
    final musics = <Music>[];
    if (e is File) {
      Music? music = await _fetchTags(e);
      if (music != null) {
        musics.add(music);
      }
    } else if (e is Directory) {
      await for (var file in e.list(recursive: recursive, followLinks: false)) {
        if (file is File) {
          Music? music = await _fetchTags(file);
          if (music != null) {
            musics.add(music);
          }
        }
      }
    } else {
      debugPrint("[$tag]_fetchMusicsIn on $e: Skipped.");
    }

    return musics;
  }

  Future<Music?> _fetchTags(File file) async {
    final metadata = await MetadataRetriever.fromFile(file);
    return Music(
      path: file.path,
      title: metadata.trackName,
      artists: metadata.trackArtistNames ?? [],
      album: metadata.albumName,
      albumArtist: metadata.albumArtistName,
    );
  }
}
