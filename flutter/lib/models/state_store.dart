import 'dart:io';

import 'music.dart';

enum KeepState {
  /// default state, never explicitly kept or deleted
  unspecified,

  /// user marked the music as kept
  kept,

  /// user marked the music as deleted
  deleted;
}

mixin StateStore {
  /// Registers the given musics into the [StateStore]
  /// their default state is [KeepState.unspecified]
  Future<void> startTracking(List<Music> musics);

  /// Dumps a (long) string that describes the state of the given musics
  /// to the given [IOSink], typically an open [File].
  Future<void> exportState(List<Music> musics, IOSink sink);

  /// Stops tracking the state of the given musics.
  /// Stream obtained with [watchState] of these musics will close
  Future<void> discardState(List<Music> musics);

  /// Mark a music with the given state for the exporter.
  /// Music should have been tracked with [startTracking] beforehand
  Future<void> markAs(Music music, KeepState state);

  /// Stream with up-to-date musics with the given state
  Stream<List<Music>> musicsForState(KeepState state);

  /// Returns a stream yielding the current state of the given music.
  /// Music should have been tracked with [startTracking] beforehand
  Stream<KeepState> watchState(Music music, {bool fireImmediately = true});
}
