import 'package:just_audio/just_audio.dart';

import 'playlist.dart';

mixin PlayerController {
  /// Attaches a [PlayerQueueNotifier] to this [PlayerController]
  /// Should be called at least once before calling other methods
  Future<void> attachPlaylistController(PlayerQueueNotifier controller);

  /// Plays the song at the given index,
  /// or just toggles playing state on the current music is index is null
  Future<void> play({int? index});

  Future<void> pause();

  Future<void> previous();

  Future<void> next();

  Future<void> seekTo(Duration duration);
}

mixin PlayerState {
  bool get isPlaying;

  bool get isPaused => !isPlaying;

  Duration get playerPosition;

  Duration get playerBufferedPosition;

  Duration? get currentMusicDuration;

  int? get indexInPlaylist;
}

mixin PlayerStateObserver {
  Stream<bool> get isPlayingStream;

  Stream<Duration> get playerPositionStream;

  Stream<Duration> get playerBufferedPositionStream;

  Stream<Duration?> get currentMusicDurationStream;

  Stream<int?> get indexInPlaylistStream;
}

abstract class PlayerStateController
    with PlayerController, PlayerState, PlayerStateObserver {}

/// Controls player and exposes its state
class JustAudioPlayerController extends PlayerStateController {
  static const tag = "PlayerProvider";

  late JustAudioQueueNotifier _playlistController;
  final AudioPlayer _player = AudioPlayer();

  // ===========================================================================
  // PlayerController
  @override
  Future<void> attachPlaylistController(PlayerQueueNotifier controller) async {
    if (controller is JustAudioQueueNotifier) {
      _playlistController = controller;
      _player.setAudioSource(controller.audioSource,
          preload: true, initialIndex: 0, initialPosition: Duration.zero);
    } else {
      throw UnsupportedError(
          "PlaylistController should be a JustAudioPlaylistController but was $controller");
    }
  }

  @override
  Future<void> play({int? index}) async {
    if (index != null) {
      await _player.seek(Duration.zero, index: index);
    }
    return await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seekTo(Duration duration) => _player.seek(duration);

  @override
  Future<void> previous() => _player.seekToPrevious();

  @override
  Future<void> next() => _player.seekToNext();

  // ===========================================================================
  // PlayerState
  @override
  int? get indexInPlaylist => _player.currentIndex;

  @override
  bool get isPlaying => _player.playing;

  @override
  Duration get playerPosition => _player.position;

  @override
  Duration get playerBufferedPosition => _player.bufferedPosition;

  @override
  Duration? get currentMusicDuration => _player.duration;

  // ===========================================================================
  // PlayerStateObserver
  @override
  Stream<int?> get indexInPlaylistStream => _player.currentIndexStream;

  @override
  Stream<bool> get isPlayingStream => _player.playingStream;

  @override
  Stream<Duration> get playerPositionStream => _player.positionStream;

  @override
  Stream<Duration> get playerBufferedPositionStream =>
      _player.bufferedPositionStream;

  @override
  Stream<Duration?> get currentMusicDurationStream => _player.durationStream;
}
