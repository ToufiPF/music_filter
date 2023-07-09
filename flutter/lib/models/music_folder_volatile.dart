import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'music.dart';
import 'music_folder.dart';

class VolatileMusic extends Music {
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

class VolatileMusicFolderBuilder
    extends MusicFolderBuilder<VolatileMusicFolder> {
  @override
  final VolatileMusicFolder root = VolatileMusicFolder("", null);

  @override
  void addMusics(VolatileMusicFolder owner, List<Music> musics) {
    owner._musics.addAll(musics);
  }

  @override
  VolatileMusicFolder addSubfolder(
      VolatileMusicFolder parent, String childPath) {
    final child = VolatileMusicFolder(childPath, parent);
    parent._folders[child.folderName] = child;
    return child;
  }
}

class VolatileMusicFolder extends MusicFolder with MutableMusicFolder {
  VolatileMusicFolder(this.path, this.parent);

  final Map<String, VolatileMusicFolder> _folders = {};
  final SplayTreeSet<Music> _musics = SplayTreeSet();

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
  Future<void> addMusics(Iterable<Music> musics) async {
    for (var m in musics) {
      final path = File(m.path).parent.path;
      final folder = await lookupOrCreate(path);
      folder._musics.add(m);
    }
  }

  @override
  Future<void> removeMusics(Iterable<Music> musics) async {
    for (var m in musics) {
      final path = File(m.path).parent.path;
      var folder = lookup(path);
      folder?._musics.remove(m);
      while (folder != null && folder.isEmpty) {
        folder.parent?._folders.remove(folder.folderName);
        folder = folder.parent;
      }
    }
  }

  @override
  Future<VolatileMusicFolder?> detachFolder(String path) async {
    VolatileMusicFolder? toDetach = lookup(path);
    toDetach?.parent?._folders.removeWhere((key, value) => value == toDetach);
    return toDetach;
  }

  @override
  VolatileMusicFolder? lookup(String path) => path.isEmpty || path == "."
      ? this
      : _lookupSplits('', path.split('/'), false);

  @override
  Future<VolatileMusicFolder> lookupOrCreate(String path) async =>
      path.isEmpty || path == "."
          ? this
          : _lookupSplits('', path.split('/'), true)!;

  VolatileMusicFolder? _lookupSplits(
      String prefix, List<String> splits, bool build) {
    if (splits.isEmpty) {
      return this;
    }
    final key = splits.first;
    // TODO use slice() once https://github.com/dart-lang/collection/issues/296 has been fixed
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
