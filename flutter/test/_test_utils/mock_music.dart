import 'package:music_filter/models/music.dart';
import 'package:path/path.dart' as p;

class MockMusic extends Music {
  MockMusic({
    required this.path,
    this.title,
    this.album,
    this.artists = const [],
    this.albumArtist,
  });

  @override
  final String path;

  @override
  final String? title;

  @override
  final String? album;

  @override
  final List<String> artists;

  @override
  final String? albumArtist;
}

List<Music> mockMusics(List<String> paths) => paths
    .map((e) => MockMusic(
          path: e,
          title: p.basenameWithoutExtension(e),
        ))
    .toList(growable: true);
