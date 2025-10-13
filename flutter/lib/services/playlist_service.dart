import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../data/entities/music.dart';
import '../data/enums/state.dart';
import '../notification.dart';

class PlaylistService {
  static const String tag = "PlaylistService";

  final ConcatenatingAudioSource _source =
      ConcatenatingAudioSource(children: []);
  int _idxCounter = 1;

  // MusicFolderDto? tracked;
  // final trackedController = StreamController<MusicFolderDto?>();
  List<Music> _tracked = [];
  final _trackedController = StreamController<List<Music>>();

  AudioSource get audioSource => _source;

  Future<void> clear() async {
    // tracked = MusicFolderDto(path: root.path);
    _tracked = [];
    await _source.clear();
    _refreshController();
  }

  List<Music> currentPlaylist() {
    return _tracked.toList(growable: false);
  }

  Stream<List<Music>> playlist() {
    // return trackedController.stream.map((folder) => folder?.allDescendants ?? []);
    return _trackedController.stream;
  }

  Future<void> insertAt(int index, Music music) async {
    _tracked.insert(index, music);
    await _source.insert(index, _musicToSource(music));
    _refreshController();
  }

  Future<void> removeAt(int index) async {
    _tracked.removeAt(index);
    await _source.removeAt(index);
    _refreshController();
  }

  Future<void> appendAll(Iterable<Music> musics) async {
    // MusicFolderDto.lookupOrCreate(tracked, prefix, splits, 0);
    for (var m in musics) {
      _tracked.add(m);
    }
    await _source
        .addAll(musics.map((m) => _musicToSource(m)).toList(growable: false));
    _refreshController();
  }

  Future<void> removeAll(Iterable<Music> musics) async {
    for (var m in musics) {
      int i;
      while ((i = _tracked.indexOf(m)) >= 0) {
        _tracked.removeAt(i);
        await _source.removeAt(i);
      }
    }

    _refreshController();
  }

  Future<void> removeTreatedMusics() async {
    // for (var i = _tracked.length; i >= 0; --i) {
    //   if (_tracked[i].state != KeepState.unspecified) {
    //     _tracked.removeAt(i);
    //     await _source.removeAt(i);
    //   }
    // }
    // _tracked.removeWhere((m) => m.state != KeepState.unspecified);
    // await _source.clear();
    // await _source.addAll(_tracked.map(_musicToSource).toList(growable: false));
    // _refreshController();
    final toRemove = _tracked.where((m) => m.state != KeepState.unspecified);
    await removeAll(toRemove);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) {
      return;
    }

    await _source.move(oldIndex, newIndex);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final toInsert = _tracked.removeAt(oldIndex);
    _tracked.insert(newIndex, toInsert);
    _refreshController();
  }

  void _refreshController() {
    _trackedController.add(currentPlaylist());
  }

  AudioSource _musicToSource(Music music) {
    final id = _idxCounter.toString();
    _idxCounter += 1;
    return AudioSource.file(music.path,
        tag: MediaItem(
          id: id,
          title: music.title ?? music.filename,
          album: music.album,
          artist: music.artists,
        ));
  }
}
