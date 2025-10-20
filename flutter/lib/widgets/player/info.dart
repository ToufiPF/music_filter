import 'package:flutter/widgets.dart';

import '../../data/entities/music.dart';
import '../../util/constants.dart';
import '_helper.dart';

class PlayingMusicInfoWidget extends StatelessWidget {
  const PlayingMusicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) =>
      PlayerHelper.playlistWithIndexStreamBuilder(context,
          (context, musics, idx) {
        Music? music = idx != null && idx < musics.length ? musics[idx] : null;
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Constants.scrollingText(music?.title ?? music?.filename ?? "N/A"),
              Constants.scrollingText(
                  "${music?.artists ?? ''} - ${music?.album ?? ''}"),
            ],
          ),
        );
      });
}
