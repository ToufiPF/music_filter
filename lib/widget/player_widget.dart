import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/music.dart';
import '../providers/player.dart';
import '../providers/playlist.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          MediaButtonsWidget(),
          PlayingMusicInfoWidget(),
        ],
      );
}

class MediaButtonsWidget extends StatelessWidget {
  const MediaButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerStateController>(context, listen: false);

    return Row(children: [
      IconButton(onPressed: player.previous, icon: Icon(Icons.skip_previous)),
      StreamBuilder<bool>(
          initialData: player.isPlaying,
          stream: player.isPlayingStream,
          builder: (context, snapshot) {
            final isPlaying = snapshot.requireData;
            return IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: isPlaying ? player.pause : player.play,
            );
          }),
      IconButton(onPressed: player.next, icon: Icon(Icons.skip_next)),
    ]);
  }
}

class PlayingMusicInfoWidget extends StatelessWidget {
  const PlayingMusicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerStateController>(context, listen: false);

    return StreamBuilder<int?>(
        stream: player.indexInPlaylistStream,
        builder: (context, snapshot) {
          final queue =
              Provider.of<PlayerQueueNotifier>(context, listen: false);

          final idx = snapshot.data;
          Music? music = idx != null ? queue.queue[idx] : null;
          return Column(
            children: [
              Text(music?.title ?? music?.filename ?? "N/A"),
              Text(music?.displayArtist ?? "N/A"),
            ],
          );
        });
  }
}
