import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as p;

import '../providers/root_folder.dart';
import 'catalog.dart';
import 'music.dart';
import 'music_folder.dart';
import 'music_folder_volatile.dart';

class VolatileCatalog extends ChangeNotifier with Catalog {
  static const String tag = "VolatileCatalog";
  static const String recycleBinName = "\$.RecycleBin";

  List<Music> _cache = [];
  VolatileMusicFolder? _toFilterRoot;
  VolatileMusicFolder? _recycledRoot;

  final RootFolderNotifier notifier;

  VolatileCatalog(this.notifier) {
    notifier.addListener(rescan);
    rescan();
  }

  @override
  void dispose() {
    super.dispose();
    notifier.removeListener(rescan);
  }

  @override
  List<Music> get allMusics => _cache.toList(growable: false);

  Directory get baseDir => notifier.rootFolder!;

  Directory get recycledDir =>
      Directory(p.join(notifier.rootFolder!.path, recycleBinName));

  @override
  Future<void> rescan() async {
    final root = notifier.rootFolder;
    debugPrint("[$tag]: Rescanning $root...");
    if (root != null) {
      final toFilter = <Music>[];
      final recycled = <Music>[];

      final toFilterBuilder = VolatileMusicFolderBuilder();
      final toFilterFuture =
          _scan(toFilterBuilder, "", toFilterBuilder.root, toFilter, root);

      final recycledBuilder = VolatileMusicFolderBuilder();
      final recycledFuture = recycledDir.exists().then((exists) => exists
          ? _scan(
              recycledBuilder, "", recycledBuilder.root, recycled, recycledDir)
          : Future.value(null));

      await toFilterFuture;
      await recycledFuture;
      _cache = toFilter + recycled;
      _toFilterRoot = toFilterBuilder.root;
      _recycledRoot = recycledBuilder.root;
      debugPrint(_toFilterRoot!.debugToString());
    } else {
      _cache.clear();
      _toFilterRoot = null;
      _recycledRoot = null;
    }
    notifyListeners();
  }

  Future<void> _scan(
    VolatileMusicFolderBuilder builder,
    String basePath,
    VolatileMusicFolder parent,
    List<Music> scanned,
    Directory folder,
  ) async {
    // the very first call should populate the root instead of creating a new subfolder
    var newFolder =
        basePath.isEmpty ? parent : builder.addSubfolder(parent, basePath);
    await for (var e in folder.list(recursive: false, followLinks: false)) {
      final name = p.basename(e.path);
      final path = p.join(basePath, name);
      if (e is Directory) {
        // skip the recycleBin, 1st child of the root folder, if it exists
        if (basePath.isEmpty && name == recycleBinName) {
          continue;
        }

        await _scan(builder, path, newFolder, scanned, e);
      } else if (e is File) {
        final music = await fetchTags(e, path);
        if (music != null) {
          builder.addMusics(newFolder, [music]);
          scanned.add(music);
        }
      }
    }
  }

  Future<Music?> fetchTags(File file, String path) async {
    try {
      final metadata =
          await MetadataRetriever.fromFile(file).timeout(Duration(seconds: 5));
      return VolatileMusic(
        path: path,
        title: metadata.trackName,
        artists: metadata.trackArtistNames ?? [],
        album: metadata.albumName,
        albumArtist: metadata.albumArtistName,
      );
    } catch (e) {
      debugPrint("[$tag]_fetchTag($path) caught error: $e");
      return null;
    }
  }

  @override
  MusicFolder? get toFilter => _toFilterRoot;

  @override
  MusicFolder? get recycleBin => _recycledRoot;

  @override
  MusicFolder? getParent(Music music) {
    final parentPath = p.dirname(music.path);
    return _toFilterRoot?.lookup(parentPath) ??
        _recycledRoot?.lookup(parentPath);
  }

  @override
  Future<void> markAsExported(Iterable<Music> musics) async {
    for (var music in musics) {
      var from = File(p.join(baseDir.path, music.path));
      if (await from.exists()) {
        var to = File(p.join(recycledDir.path, music.path));
        if (!await to.parent.exists()) {
          await to.parent.create(recursive: true);
        }
        await from.rename(to.path);
      }

      await _removeEmptyFolders(baseDir.path, from.parent);
    }

    await _toFilterRoot?.removeMusics(musics);
    await _recycledRoot?.addMusics(musics);
    notifyListeners();
  }

  @override
  Future<void> restore(Iterable<Music> musics) async {
    for (var music in musics) {
      var from = File(p.join(recycledDir.path, music.path));
      if (await from.exists()) {
        var to = File(p.join(baseDir.path, music.path));
        if (!await to.parent.exists()) {
          await to.parent.create(recursive: true);
        }
        await from.rename(to.path);
      }

      await _removeEmptyFolders(recycledDir.path, from.parent);
    }

    await _toFilterRoot?.addMusics(musics);
    await _recycledRoot?.removeMusics(musics);
    notifyListeners();
  }

  Future<void> _removeEmptyFolders(
      String upperDir, Directory toDeleteIfEmpty) async {
    if (toDeleteIfEmpty.path == upperDir) {
      return;
    }

    final empty = await toDeleteIfEmpty
        .list(recursive: false, followLinks: false)
        .isEmpty;
    if (empty) {
      await toDeleteIfEmpty.delete(recursive: false);
      await _removeEmptyFolders(upperDir, toDeleteIfEmpty.parent);
    }
  }
}
