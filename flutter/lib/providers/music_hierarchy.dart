import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import '../models/music.dart';

class MusicFolder {
  final String path;
  final MusicFolder? parent;
  final List<MusicFolder> folders = [];
  final List<Music> musics = [];

  MusicFolder(this.path, this.parent);

  bool get isRoot => parent == null;

  List<Music> get allDescendants {
    final list = musics.toList(growable: true);
    for (var folder in folders) {
      list.addAll(folder.allDescendants);
    }
    return list;
  }

  @override
  String toString() => "MusicFolder($path, parent: ${parent?.path})";
}

class MusicHierarchyNotifier extends ChangeNotifier {
  static const String tag = "MusicHierarchyNotifier";
  MusicFolder? _root;

  MusicFolder? get root => _root;

  Future<void> rescan(Directory root) async {
    debugPrint("[$tag]: Rescanning $root...");
    var parentOfRoot = MusicFolder(root.parent.path, null);
    await _scan(parentOfRoot, root, isRoot: true);
    var newRoot = parentOfRoot.folders.singleOrNull;
    debugPrint(
        "[$tag]: Scanning done: $newRoot has ${newRoot?.folders.length} subfolders "
        "and ${newRoot?.musics.length} musics");
    _root = newRoot;
    notifyListeners();
  }

  Future<void> _scan(MusicFolder parent, FileSystemEntity entity,
      {required bool isRoot}) async {
    if (entity is File) {
      Music? music = await _fetchTags(entity);
      if (music != null) {
        parent.musics.add(music);
      }
    } else if (entity is Directory) {
      var newFolder = MusicFolder(entity.path, isRoot ? null : parent);
      await entity
          .list(recursive: false, followLinks: false)
          .asyncMap((e) => _scan(newFolder, e, isRoot: false))
          .toList();
      parent.folders.add(newFolder);
    } else {
      debugPrint("[$tag]_scan($entity): Skipped.");
    }
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
