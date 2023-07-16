import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/player.dart';

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
