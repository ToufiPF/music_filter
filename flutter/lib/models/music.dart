import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

part 'music.g.dart';

enum KeepState {
  /// default state, never explicitly kept or deleted
  unspecified,

  /// user marked the music as kept
  kept,

  /// user marked the music as deleted
  deleted;
}

/// Model for a music file
@collection
class Music {
  Music({
    required this.path,
    this.title,
    this.album,
    this.artists = const [],
    this.albumArtist,
  });

  Id id = Isar.autoIncrement;

  /// Path to the music file
  @Index(unique: true, caseSensitive: true)
  final String path;

  /// Title of the track
  final String? title;

  /// Album of the track
  final String? album;

  /// Artists of the track
  final List<String> artists;

  /// Artist of the album of the track
  final String? albumArtist;

  /// State of the music, i.e. whether user specified it should be kept/deleted
  @enumerated
  KeepState state = KeepState.unspecified;

  /// Basename of the file, computed from [path]
  @ignore
  String get filename => p.basenameWithoutExtension(path);

  /// String for displaying the music's artist(s)
  @ignore
  String get displayArtist =>
      artists.isNotEmpty ? artists.join(", ") : albumArtist ?? "Unknown artist";

  @override
  String toString() => "Music($path)";
}

class MusicFolder {
  MusicFolder({required this.path, required this.parent});

  /// Path of the folder
  final String path;

  /// Parent music folder, or null if this folder is at the root
  final MusicFolder? parent;

  /// Children music folder
  final List<MusicFolder> folders = [];

  /// Direct children musics
  final List<Music> musics = [];

  /// Whether this music folder is at the root of the hierarchy
  bool get isRoot => parent == null;

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
