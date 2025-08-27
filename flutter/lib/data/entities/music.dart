import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

import '../enums/state.dart';

part 'music.g.dart';


/// Model for a music file
@Collection(inheritance: false)
class Music implements Comparable<Music> {
  Music({
    required this.path,
    this.title,
    this.album,
    this.artists,
    this.albumArtist,
  });

  /// entity id
  Id id = Isar.autoIncrement;

  /// Path to the music file, **relative to** the root
  @Index(unique: true, caseSensitive: false)
  late String path;

  /// Title of the track
  String? title;

  /// Album of the track
  String? album;

  /// Artists of the track
  String? artists;

  /// Artist of the album of the track
  String? albumArtist;

  /// Whether the music should be kept or deleted
  @Index()
  @enumerated
  KeepState state = KeepState.unspecified;

  /// Basename of the file, computed from [path]
  @ignore
  String get filename => p.basenameWithoutExtension(path);

  /// Path to the parent folder (computed from path)
  @ignore
  String get parentPath => File(path).parent.path;

  @override
  bool operator ==(Object other) => other is Music && path == other.path;

  @override
  @ignore
  int get hashCode => path.hashCode;

  @override
  int compareTo(Music other) => path.compareTo(other.path);

  @override
  String toString() => "Music($path; state: $state)";
}
