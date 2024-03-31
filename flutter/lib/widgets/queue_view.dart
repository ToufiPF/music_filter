import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../models/state_store.dart';
import '../providers/player.dart';
import '../providers/playlist.dart';
import '../widgets/context_menu.dart';
import '../widgets/player/state.dart';

class QueueView extends StatelessWidget {
  static const double iconSize = 32;
  static const prototype = ListTile(
      title: Text("Filename"),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Artist - Album"),
          Text("filename.ext"),
        ],
      ),
      isThreeLine: true,
      dense: true,
      leading: Icon(Icons.play_arrow),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          KeepStateWidget(music: null, iconSize: iconSize),
          Icon(Icons.check, size: iconSize),
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
            : ReorderableListView.builder(
                physics: NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                prototypeItem: prototype,
                itemCount: queue.queue.length,
                onReorder: queue.move,
                // Trigger rebuild only if currently played index goes to != to == or vice-versa
                itemBuilder: (context, musicIdx) => StreamBuilder<bool>(
                    key: Key(musicIdx.toString()),
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
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(music.displayArtist, maxLines: 1),
          Text(p.basename(music.path),
              maxLines: 1, style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
      isThreeLine: true,
      leading:
          Icon(isSongPlaying ? Icons.play_arrow : Icons.play_arrow_outlined),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          KeepStateWidget(music: music, iconSize: iconSize),
          StreamBuilder<KeepState>(
              initialData: KeepState.unspecified,
              stream: store.watchState(music, fireImmediately: true),
              builder: (context, snapshot) => IconActions.exportActionMusic(
                  context, music, snapshot.data!)),
        ],
      ),
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
