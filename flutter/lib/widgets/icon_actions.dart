import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/entities/music.dart';
import '../data/enums/state.dart';
import '../data/models/music_folder.dart';
import '../services/music_store_service.dart';
import '../services/playlist_service.dart';
import '../util/toast_helper.dart';

class IconActions {
  static Widget addFolderToPlaylist(
      BuildContext context, MusicFolder folder) {
    final playlist = Provider.of<PlaylistService>(context, listen: false);

    return IconButton(
        icon: const Icon(Icons.playlist_add),
        onPressed: () async {
          await playlist.appendAll(folder.allDescendants);
        });
  }

  static Widget addNonTreatedInFolderToPlaylist(
      BuildContext context, MusicFolder folder) {
    final playlist = Provider.of<PlaylistService>(context, listen: false);

    return IconButton(
        icon: const Icon(Icons.playlist_add_check),
        onPressed: () async {
          await playlist.appendAll(folder.allDescendants.where((m) => m.state == KeepState.unspecified));
        });
  }

  static Widget toggleNextState(
    KeepState targetState,
    BuildContext context,
    Music? music,
    KeepState currentState,
    { double? iconSize }
  ) {
    return currentState != targetState
        ? _markAsAction(targetState, context, music, iconSize: iconSize)
        : _markAsAction(KeepState.unspecified, context, music, iconSize: iconSize);
  }

  static Widget _markAsAction(
      KeepState state, BuildContext context, Music? music, 
    { double? iconSize }) {
    final store = Provider.of<MusicStoreService>(context, listen: false);
    return IconButton(
        icon: Icon(state.icon, size: iconSize),
        onPressed: music != null
            ? () async {
                ToastHelper.showMessageWithCancel("Marked as $state");
                await store.setState(music, state);
              }
            : null);
  }

  IconActions._();
}
