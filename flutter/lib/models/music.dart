import 'package:path/path.dart' as p;

/// Model for a music file
mixin Music {
  /// Path to the music file
  String get path;

  /// Title of the track
  String? get title;

  /// Album of the track
  String? get album;

  /// Artists of the track
  List<String> get artists;

  /// Artist of the album of the track
  String? get albumArtist;

  /// Basename of the file, computed from [path]
  String get filename => p.basenameWithoutExtension(path);

  /// String for displaying the music's artist(s)
  String get displayArtist =>
      artists.isNotEmpty ? artists.join(", ") : albumArtist ?? "Unknown artist";

  @override
  String toString() => "Music($path)";
}

mixin MusicFolder {
  /// Path of the folder
  String get path;

  /// Parent music folder, or null if this folder is at the root
  MusicFolder? get parent;

  /// Children music folder
  List<MusicFolder> get folders;

  /// Direct children musics
  List<Music> get musics;

  /// Whether this music folder is at the root of the hierarchy
  bool get isRoot => parent == null;

  /// Base name of this folder
  String get folderName => p.basename(path);

  /// Collect the list of all musics under that folder (recursively)
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
