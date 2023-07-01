import 'music.dart';

mixin StateStore {
  /// Stream with up-to-date musics with the given state
  Stream<List<Music>> musicsForState(KeepState state);

  /// Mark a music as being saved for the exporter
  Future<void> markAs(Music music, KeepState state);

  Stream<KeepState> watchState(Music music);
}
