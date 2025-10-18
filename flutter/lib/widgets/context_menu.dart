import 'package:flutter/material.dart';
import 'package:music_filter/services/music_store_service.dart';
import 'package:provider/provider.dart';

import '../data/entities/music.dart';
import '../data/enums/state.dart';
import '../data/models/music_folder.dart';
import '../services/playlist_service.dart';

class IconActions {
  static Widget addFolderToPlaylist(
      BuildContext context, MusicFolderDto folder) {
    final playlist = Provider.of<PlaylistService>(context, listen: false);

    return IconButton(
        icon: Icon(Icons.playlist_add),
        onPressed: () async {
          await playlist.appendAll(folder.allDescendants);
        });
  }

  static Widget addMusicToPlaylist(BuildContext context, Music music) {
    final playlist = Provider.of<PlaylistService>(context, listen: false);
    return IconButton(
        icon: Icon(Icons.playlist_add),
        onPressed: () async {
          await playlist.appendAll([music]);
        });
  }

  // static Widget exportActionMusic(
  //   BuildContext context,
  //   Music exported,
  //   KeepState currentState,
  // ) {
  //   final catalog = Provider.of<Catalog>(context, listen: false);
  //   final store = Provider.of<StateStore>(context, listen: false);
  //   final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
  //   return IconButton(
  //       icon: Icon(Icons.done),
  //       onPressed: currentState == KeepState.unspecified
  //           ? null
  //           : () async {
  //               final musics = [exported];
  //               await store.exportState(musics);
  //               await store.discardState(musics);
  //               await playlist.removeAll(musics);
  //               await catalog.markAsExported(musics);
  //             });
  // }

  static Widget keptMusicAction(
    BuildContext context,
    Music music,
    KeepState currentState,
  ) =>
      musicAction(
        KeepState.kept,
        context,
        music,
        currentState,
      );

  static Widget deleteMusicAction(
    BuildContext context,
    Music music,
    KeepState currentState,
  ) =>
      musicAction(
        KeepState.deleted,
        context,
        music,
        currentState,
      );

  static Widget musicAction(
    KeepState targetState,
    BuildContext context,
    Music music,
    KeepState currentState,
  ) =>
      currentState != targetState
          ? _markAsAction(targetState, context, music)
          : _markAsAction(KeepState.unspecified, context, music);

  static Widget _markAsAction(
      KeepState state, BuildContext context, Music music) {
    final store = Provider.of<MusicStoreService>(context, listen: false);
    return IconButton(
        icon: Icon(state.icon),
        onPressed: () async {
          music.state = state;
          await store.save(music);
        });
  }

  IconActions._();
}
