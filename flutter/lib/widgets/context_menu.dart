import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog.dart';
import '../models/music.dart';
import '../models/music_folder.dart';
import '../models/state_store.dart';
import '../providers/playlist.dart';

class IconActions {
  static Widget trackOrExportFolder(BuildContext context, MusicFolder folder) {
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);

    return Consumer<StateStore>(builder: (context, store, child) {
      final isTracked = store.isTrackedFolder(folder, recursive: true);
      final musics = folder.allDescendants;

      return isTracked
          ? exportActionFolder(context, folder)
          : IconButton(
              icon: Icon(Icons.playlist_add),
              onPressed: () async {
                await playlist.appendAll(musics);
                await store.startTracking(musics);
              });
    });
  }

  static Widget trackOrExportMusic(BuildContext context, Music music) {
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);

    return Consumer<StateStore>(builder: (context, store, child) {
      final isTracked = store.isTracked(music);
      final musics = [music];

      return StreamBuilder<KeepState>(
          initialData: KeepState.unspecified,
          stream: store.watchState(music, fireImmediately: true),
          builder: (context, snapshot) {
            return isTracked
                ? exportActionMusic(context, music, snapshot.data!)
                : IconButton(
                    icon: Icon(Icons.playlist_add),
                    onPressed: () async {
                      await store.startTracking(musics);
                      await playlist.appendAll(musics);
                    });
          });
    });
  }

  static Widget startTrackingFolder(BuildContext context, MusicFolder folder) {
    final store = Provider.of<StateStore>(context, listen: false);
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
    return IconButton(
        icon: Icon(Icons.playlist_add),
        onPressed: () async {
          final musics = folder.allDescendants;
          await playlist.appendAll(musics);
          await store.startTracking(musics);
        });
  }

  static Widget startTrackingMusic(BuildContext context, Music music) {
    final store = Provider.of<StateStore>(context, listen: false);
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
    return IconButton(
        icon: Icon(Icons.playlist_add),
        onPressed: () async {
          await playlist.appendAll([music]);
          await store.startTracking([music]);
        });
  }

  static Widget exportActionFolder(
    BuildContext context,
    MusicFolder exported,
  ) {
    final catalog = Provider.of<Catalog>(context, listen: false);
    final store = Provider.of<StateStore>(context, listen: false);
    return IconButton(
        icon: Icon(Icons.done_all),
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
    final playlist = Provider.of<PlayerQueueNotifier>(context, listen: false);
    return IconButton(
        icon: Icon(Icons.done),
        onPressed: currentState == KeepState.unspecified
            ? null
            : () async {
                final musics = [exported];
                await store.exportState(musics);
                await store.discardState(musics);
                await playlist.removeAll(musics);
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
            icon: Icon(Icons.restore));
  }

  IconActions._();
}
