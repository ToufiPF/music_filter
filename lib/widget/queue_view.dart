import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/playlist.dart';
import 'player_widget.dart';

class QueueView extends StatelessWidget {
  QueueView({super.key});

  final playerKey = GlobalKey<PlayerWidgetState>();

  @override
  Widget build(BuildContext context) => Consumer<PlayerQueueNotifier>(
      builder: (context, playlist, child) => playlist.currentQueue.isEmpty
          ? Text("Empty")
          : ListView.builder(
              itemCount: playlist.currentQueue.length,
              itemBuilder: (context, index) {
                final music = playlist.currentQueue[index];
                final isCurrentlyPlaying =
                    playerKey.currentState?.player.indexInPlaylist == index;
                return ListTile(
                  title: Text(music.title ?? music.filename),
                  trailing: Icon(isCurrentlyPlaying
                      ? Icons.play_arrow
                      : Icons.play_arrow_outlined),
                  onTap: isCurrentlyPlaying
                      ? null
                      : () => playerKey.currentState?.player.play(index: index),
                );
              }));
}
