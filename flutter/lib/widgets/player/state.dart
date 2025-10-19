import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../data/entities/music.dart';
import '../../data/enums/state.dart';
import '../../services/music_store_service.dart';
import '_helper.dart';

class KeepStateWidget extends StatelessWidget {
  const KeepStateWidget({
    super.key,
    required this.music,
    required this.iconSize,
  });

  final Music? music;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<MusicStoreService>(context, listen: false);

    return StreamBuilder<KeepState>(
        initialData: KeepState.unspecified,
        stream: music != null ? store.watchState(music!) : null,
        builder: (context, snapshot) {
          final nextState = snapshot.requireData.nextToggleState;
          return IconButton(
            onPressed: music != null
                ? () async {
                    Fluttertoast.cancel().then((_) =>
                        Fluttertoast.showToast(msg: "Marked as $nextState"));
                    music!.state = nextState;
                    await store.save(music!);
                  }
                : null,
            icon: Icon(nextState.icon, size: iconSize),
          );
        });
  }
}

class CurrentlyPlayingKeepStateWidget extends StatelessWidget {
  const CurrentlyPlayingKeepStateWidget({super.key, required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) =>
      PlayerHelper.playlistWithIndexStreamBuilder(context,
          (context, musics, idx) {
        Music? music = idx != null && idx < musics.length ? musics[idx] : null;
        return KeepStateWidget(music: music, iconSize: iconSize);
      });
}
