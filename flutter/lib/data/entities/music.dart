import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

import '../enums/state.dart';

part 'music.g.dart';

/// Model for a music file
@Collection(inheritance: false)
class Music implements Comparable<Music> {
  Music({
    required this.physicalPath,
    required this.virtualPath,
    this.title,
    this.album,
    this.artists,
    this.albumArtist,
  });

  /// entity id
  Id id = Isar.autoIncrement;

  /// Physical path to the music file
  @Index(unique: true, caseSensitive: true)
  late String physicalPath;

  /// Path to the music file, **relative to** the root (for display purpose)
  @Index(unique: true, caseSensitive: false)
  late String virtualPath;

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

  @Index()
  bool needsExport = false;

  /// Basename of the file, computed from [virtualPath]
  @ignore
  String get filename => p.basenameWithoutExtension(virtualPath);

  /// Path to the parent folder (computed from [virtualPath])
  @ignore
  String get parentPath => File(virtualPath).parent.path;

  @override
  bool operator ==(Object other) => other is Music && physicalPath == other.physicalPath;

  @override
  @ignore
  int get hashCode => physicalPath.hashCode;

  @override
  int compareTo(Music other) => physicalPath.compareTo(other.physicalPath);

  @override
  String toString() => "Music($physicalPath; state: $state)";
}
