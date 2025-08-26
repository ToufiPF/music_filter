import 'dart:io';

import 'package:path/path.dart' as p;

/// Model for a music file
class Music implements Comparable<Music> {
  Music({
    required this.path,
    this.title,
    this.album,
    this.artists,
    this.albumArtist,
  });

  /// entity id
  int id;

  /// Path to the music file, **relative to** the root
  final String path;

  /// Title of the track
  final String? title;

  /// Album of the track
  final String? album;

  /// Artists of the track
  final String? artists;

  /// Artist of the album of the track
  final String? albumArtist;

  /// Whether the music should be kept or deleted
  KeepState state = KeepState.unspecified;

  /// Basename of the file, computed from [path]
  String get filename => p.basenameWithoutExtension(path);

  /// Path to the parent folder (computed from path)
  String get parentPath => File(path).parent.path;

  @override
  bool operator ==(Object other) => other is Music && path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  int compareTo(Music other) => path.compareTo(other.path);

  @override
  String toString() => "Music($path; state: $state)";
}
