import 'package:isar/isar.dart';

import 'music.dart';
import 'store.dart';

class IsarStore implements Store {
  const IsarStore(this._musics);

  final IsarCollection<Music> _musics;

  @override
  Future<List<Music>> musicsWithPrefix(String pathPrefix) =>
      _musics.filter().pathStartsWith(pathPrefix).findAll();

  @override
  Future<void> loadMusics(Stream<Music> musics) async {
    final list = await musics.toList();
    await _musics.isar.writeTxn(() async {
      await _musics.clear();
      await _musics.putAll(list);
    });
  }

  @override
  Stream<List<Music>> allMusics() => _musics.where().watch();

  @override
  Stream<List<Music>> musicsForState(KeepState state) =>
      _musics.filter().stateEqualTo(state).watch();

  @override
  Future<void> markAs(Music music, KeepState newState) {
    music.state = newState;
    return _musics.isar.writeTxn(() => _musics.put(music));
  }
}
