import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import '../models/music.dart';

class MusicFolder {
  final List<MusicFolder> folders = [];
  final List<Music> directChildren = [];

  List<Music> get allDescendants {
    final list = directChildren.toList(growable: true);
    for (var folder in folders) {
      list.addAll(folder.allDescendants);
    }
    return list;
  }
}

class MusicHierarchyNotifier extends ChangeNotifier {
  static const String tag = "MusicHierarchyNotifier";
  MusicFolder? _root;

  MusicFolder? get root => _root;

  Future<void> rescan(Directory root) async {
    _root = MusicFolder();
    _scan(_root!, root);
  }

  Future<void> _scan(MusicFolder parent, FileSystemEntity entity) async {
    if (entity is File) {
      Music? music = await _fetchTags(entity);
      if (music != null) {
        parent.directChildren.add(music);
      }
    } else if (entity is Directory) {
      var newFolder = MusicFolder();
      await entity.list(recursive: false).forEach((e) => _scan(newFolder, e));
      parent.folders.add(newFolder);
    } else {
      debugPrint("[$tag]_fetchMusicsIn on $entity: Skipped.");
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
