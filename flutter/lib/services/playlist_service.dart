import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../data/entities/music.dart';
import '../data/enums/state.dart';
import '../notification.dart';

class PlaylistService {
  static const String tag = "PlaylistService";

  int _idxCounter = 1;

  // MusicFolderDto? tracked;
  // final trackedController = StreamController<MusicFolderDto?>();
  List<Music> _tracked = [];
  final _trackedController = BehaviorSubject<List<Music>>(sync: true);
  AudioPlayer? _player;

  Future<void> attachPlayer(AudioPlayer player) async {
    _player = player;
    await player.setAudioSources(audioSources,
        preload: true, initialIndex: 0, initialPosition: Duration.zero);
  }

  List<AudioSource> get audioSources =>
      _trackedController.valueOrNull
          ?.map(_musicToSource)
          .toList(growable: false) ??
      [];

  Future<void> clear() async {
    _tracked = [];
    _refreshController();
    await _player?.clearAudioSources();
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
    _refreshController();
    await _player?.insertAudioSource(index, _musicToSource(music));
  }

  Future<void> removeAt(int index) async {
    _tracked.removeAt(index);
    _refreshController();
    await _player?.removeAudioSourceAt(index);
  }

  Future<void> appendAll(Iterable<Music> musics) async {
    // MusicFolderDto.lookupOrCreate(tracked, prefix, splits, 0);
    for (var m in musics) {
      _tracked.add(m);
    }
    await _player
        ?.addAudioSources(musics.map(_musicToSource).toList(growable: false));
    _refreshController();
  }

  Future<void> removeAll(List<Music> musics) async {
    for (var m in musics) {
      int i;
      while ((i = _tracked.indexOf(m)) >= 0) {
        _tracked.removeAt(i);
        await _player?.removeAudioSourceAt(i);
      }
    }

    _refreshController();
  }

  Future<void> removeTreatedMusics() async {
    final toRemove = _tracked
        .where((m) => m.state != KeepState.unspecified)
        .toList(growable: false);
    await removeAll(toRemove);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) {
      return;
    }

    // if new index is after old index, need to subtract one b/c
    // the item is removed first at oldIndex which shifts all next indices
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final toInsert = _tracked.removeAt(oldIndex);
    _tracked.insert(newIndex, toInsert);
    _refreshController();
    await _player?.moveAudioSource(oldIndex, newIndex);
  }

  void _refreshController() {
    _trackedController.add(currentPlaylist());
  }

  AudioSource _musicToSource(Music music) {
    final id = _idxCounter.toString();
    _idxCounter += 1;
    return AudioSource.file(music.physicalPath,
        tag: MediaItem(
          id: id,
          title: music.title ?? music.filename,
          album: music.album,
          artist: music.artists,
        ));
  }
}
