import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/music.dart';
import '../../models/state_store.dart';
import '../../providers/player.dart';
import '../../providers/playlist.dart';

class NextKeepStateWidget extends StatelessWidget {
  const NextKeepStateWidget({super.key, required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerStateController>(context, listen: false);
    final store = Provider.of<StateStore>(context, listen: false);

    return Consumer<PlayerQueueNotifier>(
        builder: (context, queue, child) => StreamBuilder<int?>(
            initialData: null,
            stream: player.indexInPlaylistStream,
            builder: (context, snapshot) {
              final idx = snapshot.data;
              Music? music = idx != null && idx < queue.queue.length
                  ? queue.queue[idx]
                  : null;

              return StreamBuilder<KeepState>(
                  initialData: KeepState.unspecified,
                  stream: music != null ? store.watchState(music) : null,
                  builder: (context, snapshot) {
                    final nextState = snapshot.data!.nextToggleState;
                    return IconButton(
                      onPressed: music != null
                          ? () => store.markAs(music, nextState)
                          : null,
                      icon: Icon(
                          switch (nextState) {
                            KeepState.unspecified => Icons.restore,
                            KeepState.kept => Icons.save,
                            KeepState.deleted => Icons.delete_forever,
                          },
                          size: iconSize),
                    );
                  });
            }));
  }
}

extension _NextState on KeepState {
  KeepState get nextToggleState =>
      KeepState.values[(index + 1) % KeepState.values.length];
}
