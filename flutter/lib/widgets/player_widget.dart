import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music.dart';
import '../models/state_store.dart';
import '../providers/player.dart';
import '../providers/playlist.dart';
import 'player/seekbar.dart';

class PlayerWidget extends StatelessWidget {
  static const double mediaIconsSize = 40;
  static const double actionIconsSize = 36;

  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(child: MediaButtonsWidget(iconSize: mediaIconsSize)),
                StoreButtonsWidget(iconSize: actionIconsSize),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: SeekBarWrapper(),
            ),
            PlayingMusicInfoWidget(),
          ]);
}

class MediaButtonsWidget extends StatelessWidget {
  const MediaButtonsWidget({super.key, required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerStateController>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () => player.playerPosition.inSeconds >= 2
                ? player.seekTo(Duration.zero)
                : player.previous(),
            icon: Icon(Icons.skip_previous, size: iconSize)),
        StreamBuilder<bool>(
            initialData: player.isPlaying,
            stream: player.isPlayingStream,
            builder: (context, snapshot) {
              final isPlaying = snapshot.requireData;
              return IconButton(
                  onPressed: isPlaying ? player.pause : player.play,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                      size: iconSize));
            }),
        IconButton(
            onPressed: player.next,
            icon: Icon(Icons.skip_next, size: iconSize)),
      ],
    );
  }
}

class StoreButtonsWidget extends StatelessWidget {
  const StoreButtonsWidget({super.key, required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StateStore>(context, listen: false);
    final player = Provider.of<PlayerStateController>(context, listen: false);
    final queue = Provider.of<PlayerQueueNotifier>(context, listen: false);

    Music? currentMusic() {
      final musicIdx = player.indexInPlaylist;
      return musicIdx != null ? queue.queue[musicIdx] : null;
    }

    return Row(
      children: [
        IconButton(
            onPressed: () {
              final music = currentMusic();
              if (music != null) {
                store.markAs(music, KeepState.kept);
              }
            },
            icon: Icon(Icons.save, size: iconSize)),
        IconButton(
            onPressed: () {
              final music = currentMusic();
              if (music != null) {
                store.markAs(music, KeepState.deleted);
              }
            },
            icon: Icon(Icons.delete_forever, size: iconSize)),
      ],
    );
  }
}

class PlayingMusicInfoWidget extends StatelessWidget {
  const PlayingMusicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerStateController>(context, listen: false);
    return Consumer<PlayerQueueNotifier>(
        builder: (context, queue, child) => StreamBuilder<int?>(
            initialData: null,
            stream: player.indexInPlaylistStream,
            builder: (context, snapshot) {
              final idx = snapshot.data;
              Music? music = idx != null && idx < queue.queue.length
                  ? queue.queue[idx]
                  : null;
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(music?.title ?? music?.filename ?? "N/A"),
                    Text("${music?.displayArtist} - ${music?.album}"),
                  ],
                ),
              );
            }));
  }
}
