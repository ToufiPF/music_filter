import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/music.dart';

class PlaylistNotifier extends ChangeNotifier {
  final List<Music> _queue = [];

  List<Music> get currentQueue => _queue.toList(growable: false);

  AudioSource get audioSource => ConcatenatingAudioSource(
          useLazyPreparation: true,
          shuffleOrder: DefaultShuffleOrder(),
          children: [
            for (var (idx, music) in currentQueue.indexed)
              AudioSource.file(music.path,
                  tag: MediaItem(
                      id: idx.toString(),
                      title: music.title ?? music.path.split('/').last))
          ]);

  void clear() {
    _queue.clear();
    notifyListeners();
  }

  void appendAll(List<Music> others) {
    _queue.addAll(others);
    notifyListeners();
  }

  void insert(int index, Music other) {
    _queue.insert(index, other);
    notifyListeners();
  }
}

class CurrentMusicNotifier extends ChangeNotifier {
  final PlaylistNotifier playlist;

  CurrentMusicNotifier(this.playlist) {
    playlist.addListener(_onPlaylistUpdated);
  }

  @override
  void dispose() {
    super.dispose();
    playlist.removeListener(_onPlaylistUpdated);
  }

  Music? _currentMusic;

  Music? get currentMusic => _currentMusic;

  void _onPlaylistUpdated() {
    if (playlist.currentQueue.isEmpty) {
      _currentMusic = null;
      notifyListeners();
    }
  }
}
