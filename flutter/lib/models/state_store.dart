import 'dart:io';

import 'package:flutter/widgets.dart';

import 'music.dart';
import 'music_folder.dart';

enum KeepState {
  /// default state, never explicitly kept or deleted
  unspecified,

  /// user marked the music as kept
  kept,

  /// user marked the music as deleted
  deleted;
}

/// Exposes state of *explicitly* tracked musics
mixin StateStore on ChangeNotifier {
  /// List of musics currently tracked
  MusicFolder get openFoldersHierarchy;

  /// Registers the given musics into the [StateStore]
  /// their default state is [KeepState.unspecified]
  Future<void> startTracking(MusicFolder parent, List<Music> musics);

  /// Dumps a (long) string that describes the state of the given musics
  /// to the given [IOSink], typically an open [File].
  Future<void> exportState(List<Music> musics);

  /// Stops tracking the state of the given musics.
  /// Stream obtained with [watchState] of these musics will close
  Future<void> discardState(List<Music> musics);

  /// Mark a music with the given state for the exporter.
  /// Music should have been tracked with [startTracking] beforehand
  Future<void> markAs(Music music, KeepState state);

  /// Returns a stream yielding the current state of the given music.
  /// Music should have been tracked with [startTracking] beforehand
  Stream<KeepState> watchState(Music music, {bool fireImmediately = true});

  /// Stream with up-to-date musics with the given state
  Stream<List<Music>> musicsForState(KeepState state,
      {bool fireImmediately = true});
}
