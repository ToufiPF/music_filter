import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../models/music.dart';
import '../../providers/player.dart';
import '../../providers/playlist.dart';
import '../../util/constants.dart';

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
                    Constants.scrollingText(
                        music?.title ?? music?.filename ?? "N/A"),
                    Constants.scrollingText(
                        "${music?.displayArtist} - ${music?.album}"),
                  ],
                ),
              );
            }));
  }
}
