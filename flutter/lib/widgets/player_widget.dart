import 'package:flutter/material.dart';

import 'player/export_button.dart';
import 'player/info.dart';
import 'player/media.dart';
import 'player/remove_treated_musics.dart';
import 'player/seekbar.dart';
import 'player/state.dart';

class PlayerWidget extends StatelessWidget {
  static const double mediaIconsSize = 40;
  static const double actionIconsSize = 36;

  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) => const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                ExportButtonWidget(iconSize: actionIconsSize),
                Expanded(child: MediaButtonsWidget(iconSize: mediaIconsSize)),
                RemoveTreatedMusicsFromPlaylistButton(
                    iconSize: actionIconsSize),
                CurrentlyPlayingKeepStateWidget(iconSize: actionIconsSize),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: SeekBarWrapper(),
            ),
            PlayingMusicInfoWidget(),
          ]);
}
