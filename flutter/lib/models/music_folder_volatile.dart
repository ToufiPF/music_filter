import 'package:path/path.dart' as p;

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
