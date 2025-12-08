import 'package:just_audio/just_audio.dart';

mixin PlayerController {
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

  final AudioPlayer player = AudioPlayer();

  // ===========================================================================
  // PlayerController
  @override
  Future<void> play({int? index}) async {
    if (index != null) {
      await player.seek(Duration.zero, index: index);
    }
    return await player.play();
  }

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seekTo(Duration duration) => player.seek(duration);

  @override
  Future<void> previous() => player.seekToPrevious();

  @override
  Future<void> next() => player.seekToNext();

  // ===========================================================================
  // PlayerState
  @override
  int? get indexInPlaylist => player.currentIndex;

  @override
  bool get isPlaying => player.playing;

  @override
  Duration get playerPosition => player.position;

  @override
  Duration get playerBufferedPosition => player.bufferedPosition;

  @override
  Duration? get currentMusicDuration => player.duration;

  // ===========================================================================
  // PlayerStateObserver
  @override
  Stream<int?> get indexInPlaylistStream => player.currentIndexStream;

  @override
  Stream<bool> get isPlayingStream => player.playingStream;

  @override
  Stream<Duration> get playerPositionStream => player.positionStream;

  @override
  Stream<Duration> get playerBufferedPositionStream =>
      player.bufferedPositionStream;

  @override
  Stream<Duration?> get currentMusicDurationStream => player.durationStream;
}
