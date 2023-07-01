import 'music.dart';

abstract class Store {
  /// Loads the given musics into the store.
  /// Clears the previous list from the store.
  /// The loaded musics are yielded by [allMusics]
  Future<void> loadMusics(List<Music> musics);

  Future<List<Music>> musicsWithPrefix(String pathPrefix);

  /// Stream with up-to-date musics to filter
  Stream<List<Music>> allMusics();

  /// Stream with up-to-date musics with the given state
  Stream<List<Music>> musicsForState(KeepState state);

  Stream<KeepState> watchState(Music music);

  /// Mark a music as being saved for the exporter
  Future<void> markAs(Music music, KeepState state);
}
