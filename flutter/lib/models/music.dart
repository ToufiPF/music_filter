import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

/// Model for a music file
mixin Music {
  /// Path to the music file, **relative to** the root
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
  /// Path of the folder, **relative to** the root
  String get path;

  /// Parent music folder, or null if this folder is at the root
  MusicFolder? get parent;

  /// Children music folder
  Map<String, MusicFolder> get folders;

  /// Direct children musics
  List<Music> get musics;

  /// Whether this music folder is at the root of the hierarchy
  bool get isRoot => parent == null;

  /// Base name of this folder
  String get folderName => p.basename(path);

  /// Collect the list of all musics under that folder (recursively)
  List<Music> get allDescendants {
    final list = musics.toList(growable: true);
    for (var folder in folders.values) {
      list.addAll(folder.allDescendants);
    }
    return list;
  }

  MusicFolder? lookup(String path) => _lookupSplits(path.split('/'));

  MusicFolder? _lookupSplits(List<String> remSplits) {
    if (remSplits.isEmpty) {
      return this;
    }
    var folder = folders[remSplits.first];
    return folder?._lookupSplits(remSplits.slice(1));
  }

  @override
  String toString() => "MusicFolder($path, parent: ${parent?.path})";
}
