import 'package:path/path.dart' as p;

/// Model for a music file
class Music {
  Music({
    required this.path,
    this.title,
    this.album,
    this.artists = const [],
    this.albumArtist,
  });

  final String path;
  final String? title;
  final String? album;
  final List<String> artists;
  final String? albumArtist;

  /// Basename of the file, computed from [path]
  String get filename => p.basenameWithoutExtension(path);

  @override
  String toString() => "Music($path)";
}
