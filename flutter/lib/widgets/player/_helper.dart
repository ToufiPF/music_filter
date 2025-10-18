import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/entities/music.dart';
import '../../providers/player.dart';
import '../../services/playlist_service.dart';

class PlayerHelper {
  static StreamBuilder<(List<Music>, int?)> playlistWithIndexStreamBuilder(
      BuildContext context,
      Widget Function(BuildContext, List<Music>, int?) builderFn) {
    final playlist = Provider.of<PlaylistService>(context, listen: false);
    final player = Provider.of<PlayerStateController>(context, listen: false);
    return StreamBuilder<(List<Music>, int?)>(
        initialData: null,
        stream: CombineLatestStream.combine2(playlist.playlist(),
            player.indexInPlaylistStream, (a, b) => (a, b)),
        builder: (context, snapshot) {
          final musics = snapshot.data?.$1 ?? [];
          final idx = snapshot.data?.$2;
          return builderFn(context, musics, idx);
        });
  }

  PlayerHelper._();
}
