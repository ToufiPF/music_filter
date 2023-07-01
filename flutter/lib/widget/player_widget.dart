import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../misc.dart';
import '../models/music.dart';
import '../models/store.dart';
import '../providers/player.dart';
import '../providers/playlist.dart';

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
              child: DurationBar(),
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

class DurationBar extends StatelessWidget {
  static String formatSeconds(int seconds) {
    const minute = 60;
    const hour = 60 * minute;

    if (seconds >= hour) {
      int hours = seconds ~/ hour;
      int min = (seconds % hour) ~/ minute;
      int sec = seconds % minute;
      return "$hours:${min.toZeroPaddedString(2)}:${sec.toZeroPaddedString(2)}";
    } else {
      int min = seconds ~/ minute;
      int sec = seconds % minute;
      return "${min.toZeroPaddedString(2)}:${sec.toZeroPaddedString(2)}";
    }
  }

  const DurationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerStateController>(context, listen: false);

    return StreamBuilder(
      initialData: null,
      stream: player.currentMusicDurationStream,
      builder: (context, duration) {
        final max = duration.data?.inSeconds ?? 0;
        final maxFormatted = formatSeconds(max);
        return StreamBuilder(
          initialData: Duration.zero,
          stream: player.playerPositionStream,
          builder: (context, position) {
            final pos = position.requireData.inSeconds;
            final rem = max - pos;
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${formatSeconds(pos)} / $maxFormatted"),
                SizedBox(width: 10),
                Expanded(
                    child: LinearProgressIndicator(
                        value: max == 0 ? 0 : pos / max)),
                SizedBox(width: 10),
                Text("-${formatSeconds(rem)}"),
              ],
            );
          },
        );
      },
    );
  }
}
