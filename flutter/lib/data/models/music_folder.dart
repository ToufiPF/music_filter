import 'dart:collection';

import 'package:path/path.dart' as p;

import '../entities/music.dart';

class MusicFolder {
  static MusicFolder buildMusicHierarchy(List<Music> musics) {
    final root = MusicFolder(path: '');
    for (var m in musics) {
      final parent = lookupOrCreate(root, '', m.parentPath.split('/'), 0);
      parent.musics.add(m);
    }
    return root;
  }

  static MusicFolder lookupOrCreate(MusicFolder parent, String prefix, List<String> splits, int depth) {
    if (depth >= splits.length) {
      return parent;
    }

    final key = splits[depth];
    prefix = p.join(prefix, key);
    final child = parent.children.putIfAbsent(key, () => MusicFolder(path: prefix, parent: parent));
    return lookupOrCreate(child, prefix, splits, depth + 1);
  }

  MusicFolder({
    required this.path,
    this.parent
  });

  /// Path of the folder, **relative to** the root
  final String path;

  /// Parent music folder, or null if this folder is at the root
  final MusicFolder? parent;

  /// Children music folder
  final Map<String, MusicFolder> children = HashMap();

  /// Direct children musics
  final List<Music> musics = [];

  /// Whether this music folder is at the root of the hierarchy
  bool get isRoot => parent == null;

  /// Base name of this folder
  String get folderName => p.basename(path);

  bool get isEmpty => children.isEmpty && musics.isEmpty;

  bool get isNotEmpty => !isEmpty;

  /// Collect the list of all musics under that folder (recursively)
  List<Music> get allDescendants {
    final list = musics.toList(growable: true);
    for (var folder in children.values) {
      list.addAll(folder.allDescendants);
    }
    return list;
  }

  @override
  String toString() => "MusicFolderDto($path, parent: ${parent?.path})";

  String debugToString({int depth = 0}) {
    final buffer = StringBuffer();
    buffer.write("  " * depth);
    buffer.writeln(folderName);
    final nextDepth = depth + 1;
    for (var f in children.values) {
      buffer.write(f.debugToString(depth: nextDepth));
    }
    for (var m in musics) {
      buffer.write("  " * nextDepth);
      buffer.writeln(m.filename);
    }
    return buffer.toString();
  }
}
