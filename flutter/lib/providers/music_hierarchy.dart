import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import '../models/music.dart';

mixin MusicHierarchyNotifier on ChangeNotifier {
  MusicFolder? get root;

  Future<void> rescan(Directory root);

  List<MusicFolder> get openedFolders;

  Future<void> openFolder(MusicFolder folder, {bool recursive = true});

  Future<void> closeFolder(MusicFolder folder,
      {KeepState stateIfUnspecified = KeepState.unspecified,
      bool recursive = true});
}

class MusicHierarchyNotifierImpl extends ChangeNotifier
    with MusicHierarchyNotifier {
  static const String tag = "MusicHierarchyNotifier";
  MusicFolder? _root;

  @override
  MusicFolder? get root => _root;

  final List<MusicFolder> _opened = [];

  @override
  Future<void> rescan(Directory root) async {
    debugPrint("[$tag]: Rescanning $root...");
    var parentOfRoot = MusicFolder(path: root.parent.path, parent: null);
    await _scan(parentOfRoot, root, isRoot: true);
    var newRoot = parentOfRoot.folders.singleOrNull;
    debugPrint(
        "[$tag]: Scanning done: $newRoot has ${newRoot?.folders.length} subfolders "
        "and ${newRoot?.musics.length} musics");
    _root = newRoot;
    _opened.clear();
    notifyListeners();
  }

  @override
  List<MusicFolder> get openedFolders => _opened.toList(growable: false);

  @override
  Future<void> openFolder(MusicFolder folder, {bool recursive = false}) async {
    if (recursive) {
      await Future.forEach(
          folder.folders, (e) => openFolder(e, recursive: true));
    }
    _opened.add(folder);
    notifyListeners();
  }

  @override
  Future<void> closeFolder(MusicFolder folder,
      {KeepState stateIfUnspecified = KeepState.unspecified,
      bool recursive = true}) async {
    if (recursive) {
      await Future.forEach(
          folder.folders,
          (e) => closeFolder(e,
              stateIfUnspecified: stateIfUnspecified, recursive: true));
    }
    _opened.remove(folder);
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
      var newFolder =
          MusicFolder(path: entity.path, parent: isRoot ? null : parent);
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
