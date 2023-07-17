import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog.dart';
import '../models/music.dart';
import '../models/music_folder.dart';
import '../models/state_store.dart';

class IconActions {
  static Widget exportActionFolder(
    BuildContext context,
    MusicFolder exported,
  ) {
    final catalog = Provider.of<Catalog>(context, listen: false);
    final store = Provider.of<StateStore>(context, listen: false);
    return IconButton(
        icon: Icon(Icons.upload),
        onPressed: () async {
          final musics = exported.allDescendants;
          await store.exportState(musics);
          await store.discardState(musics);
          await catalog.markAsExported(musics);
        });
  }

  static Widget exportActionMusic(
    BuildContext context,
    Music exported,
    KeepState currentState,
  ) {
    final catalog = Provider.of<Catalog>(context, listen: false);
    final store = Provider.of<StateStore>(context, listen: false);
    return IconButton(
        icon: Icon(Icons.upload),
        onPressed: currentState == KeepState.unspecified
            ? null
            : () async {
                final musics = [exported];
                await store.exportState(musics);
                await store.discardState(musics);
                await catalog.markAsExported(musics);
              });
  }

  static Widget keptMusicAction(
    BuildContext context,
    Music music,
    KeepState currentState,
  ) =>
      _musicAction(
        KeepState.kept,
        Icons.save,
        context,
        music,
        currentState,
      );

  static Widget deleteMusicAction(
    BuildContext context,
    Music music,
    KeepState currentState,
  ) =>
      _musicAction(
        KeepState.deleted,
        Icons.delete_forever,
        context,
        music,
        currentState,
      );

  static Widget _musicAction(
    KeepState targetState,
    IconData icon,
    BuildContext context,
    Music music,
    KeepState currentState,
  ) {
    final store = Provider.of<StateStore>(context, listen: false);
    return currentState != targetState
        ? IconButton(
            onPressed: () => store.markAs(music, targetState), icon: Icon(icon))
        : IconButton(
            onPressed: () => store.markAs(music, KeepState.unspecified),
            icon: Icon(Icons.refresh));
  }

  IconActions._();
}
