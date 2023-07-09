import 'package:path/path.dart' as p;

/// Model for a music file
abstract class Music implements Comparable<Music> {
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
  bool operator ==(Object other) => other is Music && path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  int compareTo(Music other) => path.compareTo(other.path);

  @override
  String toString() => "Music($path)";
}
