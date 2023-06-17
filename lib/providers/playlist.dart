import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/music.dart';

mixin PlayerQueueNotifier on ChangeNotifier {
  List<Music> get currentQueue;

  void appendToQueue(List<Music> musics);

  void insertInQueue(int index, Music music);

  void removeFromQueue(int index);

  void clearQueue();
}

class JustAudioQueueNotifier extends ChangeNotifier with PlayerQueueNotifier {
  final ConcatenatingAudioSource _source =
      ConcatenatingAudioSource(children: []);

  final List<Music> _currentQueue = [];

  AudioSource get audioSource => _source;

  @override
  List<Music> get currentQueue => _currentQueue.toList(growable: false);

  @override
  void appendToQueue(List<Music> musics) {
    _source
        .addAll(musics.map((e) => _musicToSource(e)).toList(growable: false));
    _currentQueue.addAll(musics);

    notifyListeners();
  }

  @override
  void insertInQueue(int index, Music music) {
    _source.add(_musicToSource(music));
    _currentQueue.insert(index, music);
    notifyListeners();
  }

  @override
  void removeFromQueue(int index) {
    _source.removeAt(index);
    _currentQueue.removeAt(index);
    notifyListeners();
  }

  @override
  void clearQueue() {
    _source.clear();
    _currentQueue.clear();
    notifyListeners();
  }

  AudioSource _musicToSource(Music music) => AudioSource.file(music.path,
      tag: MediaItem(
        id: music.path,
        title: music.title ?? music.filename,
        album: music.album,
        artist: music.artists.isNotEmpty
            ? music.artists.join(", ")
            : music.albumArtist,
      ));
}
