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

  @Index(unique: true, caseSensitive: true)
  final String path;
  final String? title;
  final String? album;
  final List<String> artists;
  final String? albumArtist;

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
