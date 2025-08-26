
class MusicFolderDto {
  MusicFolderDto({
    required this.path,
    this.parent
  });

  /// Path of the folder, **relative to** the root
  final String path;

  /// Parent music folder, or null if this folder is at the root
  final MusicFolderDto? parent;

  /// Children music folder
  final Dictionary<String, MusicFolderDto> children = [];

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
    for (var folder in children) {
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
