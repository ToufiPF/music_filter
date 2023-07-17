import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/state_store.dart';
import '../providers/player.dart';
import '../providers/playlist.dart';
import 'context_menu.dart';

class QueueView extends StatelessWidget {
  static const prototype = ListTile(
      title: Text("Filename"),
      subtitle: Text("Artist - Album"),
      dense: true,
      leading: Icon(Icons.play_arrow),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(onPressed: null, icon: Icon(Icons.save)),
          IconButton(onPressed: null, icon: Icon(Icons.delete_forever)),
          IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
        ],
      ));

  const QueueView({super.key});

  @override
  Widget build(BuildContext context) =>
      Consumer2<PlayerQueueNotifier, PlayerStateController>(
          builder: (context, queue, player, child) {
        final store = Provider.of<StateStore>(context, listen: false);
        return queue.queue.isEmpty
            ? Center(
                child: Text("Nothing to play !\n"
                    "Start by adding some songs to the queue"))
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                prototypeItem: prototype,
                itemCount: queue.queue.length,
                // Trigger rebuild only if currently played index goes to != to == or vice-versa
                itemBuilder: (context, musicIdx) => StreamBuilder<bool>(
                    initialData: player.indexInPlaylist == musicIdx,
                    stream: player.indexInPlaylistStream
                        .map((currentIdx) => currentIdx == musicIdx),
                    builder: (context, snapshot) => _buildTile(
                          context,
                          queue,
                          player,
                          store,
                          musicIdx,
                          snapshot.requireData,
                        )));
      });

  Widget _buildTile(
    BuildContext context,
    PlayerQueueNotifier queue,
    PlayerStateController player,
    StateStore store,
    int musicIdx,
    bool isSongPlaying,
  ) {
    final music = queue.queue[musicIdx];
    return ListTile(
      dense: true,
      selected: isSongPlaying,
      title: Text(music.title ?? music.filename, maxLines: 1),
      subtitle: Text(music.displayArtist, maxLines: 1),
      leading:
          Icon(isSongPlaying ? Icons.play_arrow : Icons.play_arrow_outlined),
      trailing: StreamBuilder<KeepState>(
          initialData: KeepState.unspecified,
          stream: store.watchState(music, fireImmediately: true),
          builder: (context, snapshot) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconActions.keptMusicAction(context, music, snapshot.data!),
                IconActions.deleteMusicAction(context, music, snapshot.data!),
                PopupMenuButton<int>(
                    child: Icon(Icons.more_vert, size: 32),
                    itemBuilder: (context) => [],
                    onSelected: (selectedAction) {}),
              ],
            );
          }),
      onTap: () {
        // if song is currently playing, don't call play()
        // as this would reset the time to 0
        if (isSongPlaying && player.isPlaying) {
          return;
        }

        player.play(index: musicIdx);
      },
    );
  }
}
