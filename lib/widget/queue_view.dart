import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player.dart';
import '../providers/playlist.dart';
import 'context_menu.dart';

class QueueView extends StatelessWidget {
  /// Actions that will popup when clicking on the "..." next to a queue item
  static const popupActions = [MenuAction.removeFromPlaylist];

  const QueueView({super.key});

  @override
  Widget build(BuildContext context) =>
      Consumer2<PlayerQueueNotifier, PlayerStateController>(
          builder: (context, queue, player, child) => queue.queue.isEmpty
              ? Text("Nothing to play !\n"
                  "Start by adding some songs to the queue")
              : ListView.builder(
                  itemCount: queue.queue.length,
                  itemBuilder: (context, musicIdx) {
                    final music = queue.queue[musicIdx];
                    // Trigger rebuild only if currently played index goes to != to == or vice-versa
                    return StreamBuilder<bool>(
                        initialData: player.indexInPlaylist == musicIdx,
                        stream: player.indexInPlaylistStream
                            .map((currentIdx) => currentIdx == musicIdx),
                        builder: (context, snapshot) {
                          final isSongPlaying = snapshot.requireData;
                          return ListTile(
                            selected: isSongPlaying,
                            title: Text(music.title ?? music.filename),
                            subtitle: Text(music.displayArtist),
                            leading: Icon(isSongPlaying
                                ? Icons.play_arrow
                                : Icons.play_arrow_outlined),
                            trailing: PopupMenuButton<int>(
                              child: Icon(Icons.more_vert, size: 32),
                              itemBuilder: (context) => [
                                for (var action in popupActions)
                                  PopupMenuItem<int>(
                                      value: action.index,
                                      child: Text(action.text)),
                              ],
                              onSelected: (selectedAction) =>
                                  _onPopupMenuAction(
                                context,
                                queue,
                                player,
                                MenuAction.values[selectedAction],
                                musicIdx,
                              ),
                            ),
                            onTap: () {
                              if (isSongPlaying && player.isPlaying) {
                                return;
                              }

                              player.play(index: musicIdx);
                            },
                          );
                        });
                  }));

  Future<void> _onPopupMenuAction(
    BuildContext context,
    PlayerQueueNotifier queue,
    PlayerStateController player,
    MenuAction action,
    int musicIdx,
  ) async {
    switch (action) {
      case MenuAction.removeFromPlaylist:
        queue.removeAt(musicIdx);
        break;
      default:
        throw StateError("Clicked on unsupported menu item $action");
    }
  }
}
