import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as p;

import '../providers/root_folder.dart';
import 'catalog.dart';
import 'music.dart';
import 'music_folder.dart';

class VolatileMusic with Music {
  VolatileMusic({
    required this.path,
    this.title,
    this.album,
    this.artists = const [],
    this.albumArtist,
  });

  @override
  final String path;

  @override
  final String? title;

  @override
  final String? album;

  @override
  final List<String> artists;

  @override
  final String? albumArtist;
}

class VolatileMusicFolder with MusicFolder, MutableMusicFolder {
  VolatileMusicFolder(this.path, this.parent);

  final Map<String, VolatileMusicFolder> _folders = {};
  final List<Music> _musics = [];

  @override
  final String path;

  @override
  final VolatileMusicFolder? parent;

  @override
  List<VolatileMusicFolder> get children =>
      _folders.values.toList(growable: false);

  @override
  List<Music> get musics => _musics.toList(growable: false);

  @override
  void addMusics(Iterable<Music> musics) {
    for (var m in musics) {
      if (!_musics.contains(m)) {
        _musics.add(m);
      }
    }
  }

  @override
  void removeMusics(Iterable<Music> musics) {
    for (var m in musics) {
      _musics.remove(m);
    }
  }

  @override
  VolatileMusicFolder? detachFolder(String path) {
    VolatileMusicFolder? toDetach = lookup(path);
    toDetach?.parent?._folders.removeWhere((key, value) => value == toDetach);
    return toDetach;
  }

  @override
  VolatileMusicFolder? lookup(String path) => path.isEmpty || path == "."
      ? this
      : _lookupSplits('', path.split('/'), false);

  @override
  VolatileMusicFolder lookupOrCreate(String path) => path.isEmpty || path == "."
      ? this
      : _lookupSplits('', path.split('/'), true)!;

  VolatileMusicFolder? _lookupSplits(
      String prefix, List<String> splits, bool build) {
    if (splits.isEmpty) {
      return this;
    }
    final key = splits.first;
    // TODO use slice() once
    //  https://github.com/dart-lang/collection/issues/296 has been fixed
    final remaining = splits.sublist(1);
    if (build) {
      prefix = p.join(prefix, key);
      final child =
          _folders.putIfAbsent(key, () => VolatileMusicFolder(prefix, this));
      return child._lookupSplits(prefix, remaining, true);
    } else {
      final child = _folders[key];
      return child?._lookupSplits(prefix, remaining, false);
    }
  }
}

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

  Future<void> rescan() async {
    final root = notifier.rootFolder;
    debugPrint("[$tag]: Rescanning $root...");
    if (root != null) {
      final toFilter = <Music>[];
      final recycled = <Music>[];

      final toFilterRoot = _scan("", null, toFilter, root);
      final recycledRoot = (await recycledDir.exists())
          ? _scan("", null, recycled, recycledDir)
          : null;

      _cache = toFilter + recycled;
      _toFilterRoot = await toFilterRoot;
      _recycledRoot = await recycledRoot;
      debugPrint(
          "[$tag]: Scanning done: $_toFilterRoot has ${toFilter.length} musics");
      notifyListeners();
    } else {
      _cache.clear();
      _toFilterRoot = null;
      _recycledRoot = null;
    }
  }

  Future<VolatileMusicFolder> _scan(
    String basePath,
    VolatileMusicFolder? parent,
    List<Music> scanned,
    Directory folder,
  ) async {
    var newFolder = VolatileMusicFolder(basePath, parent);
    await for (var e in folder.list(recursive: false, followLinks: false)) {
      final name = p.basename(e.path);
      final path = p.join(basePath, name);
      if (e is Directory) {
        // skip the recycleBin, 1st child of the root folder, if it exists
        if (basePath == "" && name == recycleBinName) {
          continue;
        }

        final sub = await _scan(path, newFolder, scanned, e);
        newFolder._folders[name] = sub;
      } else if (e is File) {
        final music = await fetchTags(e, path);
        if (music != null) {
          newFolder._musics.add(music);
          scanned.add(music);
        }
      }
    }
    return newFolder;
  }

  Future<Music?> fetchTags(File file, String path) async {
    final metadata = await MetadataRetriever.fromFile(file);
    return VolatileMusic(
      path: path,
      title: metadata.trackName,
      artists: metadata.trackArtistNames ?? [],
      album: metadata.albumName,
      albumArtist: metadata.albumArtistName,
    );
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
    }
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
    }
  }
}
