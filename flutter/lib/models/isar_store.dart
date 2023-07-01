import 'dart:async';

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
  Future<void> loadMusics(List<Music> musics) async {
    await _musics.isar.writeTxn(() async {
      await _musics.clear();
      await _musics.putAll(musics);
    });
  }

  @override
  Stream<List<Music>> allMusics() =>
      _musics.where().watch(fireImmediately: true);

  @override
  Stream<List<Music>> musicsForState(KeepState state) =>
      _musics.filter().stateEqualTo(state).watch(fireImmediately: true);

  @override
  Future<void> markAs(Music music, KeepState state) {
    music.state = state;
    _controllers[music.id]?.add(state);
    return _musics.isar.writeTxn(() => _musics.put(music));
  }

  @override
  Stream<KeepState> watchState(Music music) {
    late final StreamController<KeepState> controller;

    controller = _controllers.putIfAbsent(
      music.id,
      () => StreamController<KeepState>.broadcast(
        sync: false,
        onCancel: () {
          if (controller.hasListener) {
            _controllers.remove(music.id);
          }
        },
      ),
    );

    return controller.stream;
  }
}
