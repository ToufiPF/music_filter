import 'package:path/path.dart' as p;

import 'music.dart';

typedef MusicFolderFactory = MusicFolder Function(
    String path, MusicFolder? parent);

abstract class MusicFolderBuilder<Folder extends MusicFolder> {
  Folder get root;

  Folder addSubfolder(Folder parent, String childPath);

  void addMusics(Folder owner, List<Music> musics);
}

// TODO lookup/add/remove tests
mixin MusicFolder {
  /// Path of the folder, **relative to** the root
  String get path;

  /// Parent music folder, or null if this folder is at the root
  MusicFolder? get parent;

  /// Children music folder
  List<MusicFolder> get children;

  /// Direct children musics
  List<Music> get musics;

  /// Whether this music folder is at the root of the hierarchy
  bool get isRoot => parent == null;

  /// Base name of this folder
  String get folderName => p.basename(path);

  /// Collect the list of all musics under that folder (recursively)
  List<Music> get allDescendants {
    final list = musics.toList(growable: true);
    for (var folder in children) {
      list.addAll(folder.allDescendants);
    }
    return list;
  }

  /// Searches down the tree hierarchy and returns the folder if it exists,
  /// null otherwise
  MusicFolder? lookup(String path);

  @override
  String toString() => "MusicFolder($path, parent: ${parent?.path})";

  String debugToString({int depth = 0}) {
    final buffer = StringBuffer();
    buffer.write("  " * depth);
    buffer.writeln(folderName);
    final nextDepth = depth + 1;
    for (var f in children) {
      buffer.write(f.debugToString(depth: nextDepth));
    }
    for (var m in musics) {
      buffer.write("  " * nextDepth);
      buffer.writeln(m.filename);
    }
    return buffer.toString();
  }
}

mixin MutableMusicFolder on MusicFolder {
  @override
  MutableMusicFolder? lookup(String path);

  /// Searches down the tree hierarchy and returns the folder,
  /// creating it and all its ancestors if they do not exist
  Future<MutableMusicFolder> lookupOrCreate(String path);

  /// Looks up the folder and detaches it if it exists
  Future<MusicFolder?> detachFolder(String path);

  Future<void> addMusics(Iterable<Music> musics);

  Future<void> removeMusics(Iterable<Music> musics);
}
