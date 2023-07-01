import 'dart:async';

import 'package:isar/isar.dart';

import 'music.dart';
import 'store.dart';

class IsarStateStore with StateStore {
  IsarStateStore(this._musics);

  final IsarCollection<Music> _musics;

  @override
  Stream<List<Music>> musicsForState(KeepState state) =>
      _musics.filter().stateEqualTo(state).watch(fireImmediately: true);

  @override
  Future<void> markAs(Music music, KeepState state) {
    music.state = state;
    return _musics.isar.writeTxn(() => _musics.put(music));
  }

  @override
  Stream<KeepState> watchState(Music music) => _musics
      .watchObject(music.id)
      .map((e) => e?.state ?? KeepState.unspecified);
}
