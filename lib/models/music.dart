/// Model for a music file
class Music {
  final String path;
  final String? title;
  final String? album;
  final List<String> artists;
  final String? albumArtist;

  Music({
    required this.path,
    this.title,
    this.album,
    this.artists = const [],
    this.albumArtist,
  });

  @override
  String toString() => "Music($path)";
}
