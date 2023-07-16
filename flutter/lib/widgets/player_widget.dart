import 'package:flutter/material.dart';

import 'player/info.dart';
import 'player/media.dart';
import 'player/seekbar.dart';
import 'player/state.dart';

class PlayerWidget extends StatelessWidget {
  static const double mediaIconsSize = 40;
  static const double actionIconsSize = 36;

  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(child: MediaButtonsWidget(iconSize: mediaIconsSize)),
                NextKeepStateWidget(iconSize: actionIconsSize),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: SeekBarWrapper(),
            ),
            PlayingMusicInfoWidget(),
          ]);
}
