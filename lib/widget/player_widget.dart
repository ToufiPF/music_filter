import 'package:flutter/cupertino.dart';

import '../providers/player.dart';
import '../providers/playlist.dart';

class PlayerWidget extends StatefulWidget {
  PlayerWidget() : super(key: PlayerWidgetState.key);

  @override
  State<PlayerWidget> createState() => PlayerWidgetState();
}

class PlayerWidgetState extends State<PlayerWidget> {
  static final key = GlobalKey<PlayerWidgetState>();

  late final PlayerStateController player;
  late final PlayerQueueNotifier playlist;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
