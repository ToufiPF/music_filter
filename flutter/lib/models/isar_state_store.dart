import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';

import 'music.dart';
import 'state_store.dart';

part 'isar_state_store.g.dart';

@collection
class MusicState {
  MusicState(this.musicId, this.state);

  final Id musicId;

  @enumerated
  @Index(unique: false)
  final KeepState state;
}

class IsarStateStore with StateStore {
  static const tag = "IsarCatalog";

  IsarStateStore({required Isar isarDb})
      : _musics = isarDb.musics,
        _states = isarDb.musicStates;

  final IsarCollection<Music> _musics;
  final IsarCollection<MusicState> _states;

  @override
  Future<void> startTracking(List<Music> musics) async {
    final ids = _getIds(musics);

    final fetched = await _states.getAll(ids);
    final alreadyTracked = fetched.whereNotNull().map((e) => e.musicId).toSet();

    final newEntries = ids
        .whereNot((id) => alreadyTracked.contains(id))
        .map((id) => MusicState(id, KeepState.unspecified))
        .toList(growable: false);
    await _states.isar.writeTxn(() => _states.putAll(newEntries));
  }

  @override
  Future<void> exportState(List<Music> musics, IOSink sink) async {
    final ids = _getIds(musics);
    final states = (await _states.getAll(ids)).whereNotNull();

    final idsMap = Map.fromIterables(ids, musics);
    for (var entry in states) {
      var music = idsMap[entry.musicId]!;
      sink.writeln("\"${music.path}\",${entry.state}");
    }
    await sink.flush();
  }

  @override
  Future<void> discardState(List<Music> musics) =>
      _states.isar.writeTxn(() => _states.deleteAll(_getIds(musics)));

  List<Id> _getIds(Iterable<Music> musics) =>
      musics.map((e) => e.id).toList(growable: false);

  @override
  Stream<List<Music>> musicsForState(KeepState state) => _states
      .where()
      .stateEqualTo(state)
      .watch(fireImmediately: true)
      .map((entries) => entries.map((e) => e.musicId).toList(growable: false))
      .asyncMap((ids) => _musics.getAll(ids))
      .map((musics) => musics.whereNotNull().toList(growable: false));

  @override
  Future<void> markAs(Music music, KeepState state) {
    final entry = MusicState(music.id, state);
    return _states.isar.writeTxn(() => _states.put(entry));
  }

  @override
  Stream<KeepState> watchState(Music music, {bool fireImmediately = true}) {
    debugPrint("Watching state of $music ${music.id}");
    return _states
        .watchObject(music.id, fireImmediately: fireImmediately)
        .map((e) => e?.state ?? KeepState.unspecified);
  }
}
