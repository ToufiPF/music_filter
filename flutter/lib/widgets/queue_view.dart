import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../data/entities/music.dart';
import '../providers/player.dart';
import '../services/playlist_service.dart';
import '../util/constants.dart';
import '../widgets/player/state.dart';

class QueueView extends StatelessWidget {
  static const double iconSize = 28;
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
        ],
      ));

  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final playlist = Provider.of<PlaylistService>(context, listen: false);
    final player = Provider.of<PlayerStateController>(context, listen: false);

    return StreamBuilder<List<Music>>(
      initialData: [],
      stream: playlist.playlist(),
      builder: (context, snapshot) {
        final musics = snapshot.requireData;
        return musics.isEmpty
            ? Center(
                child: Text("Nothing to play !\n"
                    "Start by adding some songs to the queue"))
            : ReorderableListView.builder(
                physics: NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                prototypeItem: prototype,
                itemCount: musics.length,
                onReorder: playlist.reorder,
                // Trigger rebuild only if currently played index goes to != to == or vice-versa
                itemBuilder: (context, musicIdx) => StreamBuilder<bool>(
                    key: Key(musicIdx.toString()),
                    initialData: player.indexInPlaylist == musicIdx,
                    stream: player.indexInPlaylistStream
                        .map((currentIdx) => currentIdx == musicIdx),
                    builder: (context, snapshot2) => _buildTile(
                          context,
                          player,
                          musics,
                          musicIdx,
                          snapshot2.requireData,
                        )));
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    PlayerStateController player,
    List<Music> playlistQueue,
    int musicIdx,
    bool isSongPlaying,
  ) {
    final music = playlistQueue[musicIdx];
    return ListTile(
      dense: true,
      selected: isSongPlaying,
      title: Constants.scrollingText(music.title ?? music.filename),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Constants.scrollingText(music.artists ?? music.albumArtist ?? ''),
          Constants.scrollingText(p.basename(music.virtualPath),
              style: TextStyle(fontStyle: FontStyle.italic)),
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
