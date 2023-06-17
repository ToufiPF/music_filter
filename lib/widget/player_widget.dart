import 'package:flutter/cupertino.dart';
import 'package:music_filter/providers/player.dart';

import '../providers/playlist.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({super.key});

  @override
  State<PlayerWidget> createState() => PlayerWidgetState();
}

class PlayerWidgetState extends State<PlayerWidget> {
  late final PlayerStateController player;
  late final PlayerQueueNotifier playlist;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
