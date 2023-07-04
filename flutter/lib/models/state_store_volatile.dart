import 'dart:async';
import 'dart:io';

import 'music.dart';
import 'state_store.dart';

class VolatileStateStore with StateStore {
  final Map<String, KeepState> _states = {};
  final Map<String, List<StreamController<KeepState>>> _controllers = {};

  final Map<KeepState, List<Music>> _musicsPerState = {};
  final Map<KeepState, List<StreamController<List<Music>>>> _musicsControllers =
      {};

  @override
  Future<void> startTracking(List<Music> musics) async {
    const state = KeepState.unspecified;
    for (var music in musics) {
      _states.putIfAbsent(music.path, () => state);
      _controllers[music.path]?.forEach((controller) => controller.add(state));
    }

    final updated = _musicsPerState.putIfAbsent(state, () => []);
    updated.addAll(musics);
    _musicsControllers[state]?.addForEach(updated);
  }

  @override
  Future<void> exportState(List<Music> musics, IOSink sink) {
    for (var music in musics) {
      final state = _states[music.path] ?? KeepState.unspecified;
      sink.writeln("${music.path}, $state");
    }
    return sink.flush();
  }

  @override
  Future<void> discardState(List<Music> musics) async {
    for (var music in musics) {
      final state = _states.remove(music.path);
      if (state != null) {
        final list = _musicsPerState[state];
        if (list != null) {
          list.remove(music);
          _musicsControllers[state]?.addForEach(list);
        }
      }
      _controllers.remove(music.path)?.forEach((e) => e.close());
    }
  }

  @override
  Future<void> markAs(Music music, KeepState state) async {
    final oldState = _states[music.path];
    if (oldState != null) {
      final oldList = _musicsPerState[oldState];
      if (oldList != null) {
        oldList.remove(music);
        _musicsControllers[oldState]?.addForEach(oldList);
      }
    }
    _states[music.path] = state;
    _controllers[music.path]?.addForEach(state);

    final newList = _musicsPerState.putIfAbsent(state, () => []);
    newList.add(music);
    _musicsControllers[state]?.addForEach(newList);
  }

  @override
  Stream<KeepState> watchState(Music music, {bool fireImmediately = true}) {
    final controller = StreamController<KeepState>(sync: false);

    controller
      ..onListen = () {
        var list = _controllers.putIfAbsent(music.path, () => []);
        list.add(controller);
        if (fireImmediately) {
          controller.add(_states[music.path] ?? KeepState.unspecified);
        }
      }
      ..onCancel = () {
        _controllers[music.path]?.remove(controller);
      };

    controller
      ..onResume = controller.onListen
      ..onPause = controller.onCancel;

    return controller.stream;
  }

  @override
  Stream<List<Music>> musicsForState(KeepState state,
      {bool fireImmediately = true}) {
    final controller = StreamController<List<Music>>(sync: false);

    controller
      ..onListen = () {
        var list = _musicsControllers.putIfAbsent(state, () => []);
        list.add(controller);
        if (fireImmediately) {
          controller.add(_musicsPerState[state] ?? []);
        }
      }
      ..onCancel = () {
        _musicsControllers[state]?.remove(controller);
      };

    controller
      ..onResume = controller.onListen
      ..onPause = controller.onCancel;

    return controller.stream;
  }
}

extension _ControllersExt<T> on List<StreamController<T>> {
  void addForEach(T event) {
    for (var controller in this) {
      controller.add(event);
    }
  }
}
