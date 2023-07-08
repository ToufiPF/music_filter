import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_filter/models/music_folder.dart';
import 'package:provider/provider.dart';

import '../models/catalog.dart';
import '../models/state_store.dart';

class OpenMusicView extends StatefulWidget {
  const OpenMusicView({super.key});

  @override
  State<OpenMusicView> createState() => _OpenMusicViewState();
}

class _OpenMusicViewState extends State<OpenMusicView> {
  late String path;

  @override
  void initState() {
    super.initState();
    path = "";
  }

  @override
  Widget build(BuildContext context) {
    final catalog = Provider.of<Catalog>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        if (path.isNotEmpty) {
          setState(() => path = Directory(path).parent.path);
          return false;
        }
        return true;
      },
      child: Consumer<StateStore>(builder: (builder, store, child) {
        final root = store.openFoldersHierarchy;
        final toDisplay = root.lookup(path)!;
        return ListView.builder(
          itemCount: toDisplay.children.length + toDisplay.musics.length,
          itemBuilder: (context, idx) {
            if (idx < toDisplay.children.length) {
              final folder = toDisplay.children[idx];
              return ListTile(
                title: Text(folder.folderName),
                onTap: () => setState(() => path = folder.path),
                trailing: _uploadIconButton(catalog, store, toDisplay),
              );
            } else {
              idx -= toDisplay.children.length;
              final music = toDisplay.musics[idx];
              return ListTile(
                title: Text(music.title ?? music.filename),
                trailing: StreamBuilder<KeepState>(
                    initialData: KeepState.unspecified,
                    stream: store.watchState(music, fireImmediately: true),
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: snapshot.data != KeepState.kept
                                ? () => store.markAs(music, KeepState.kept)
                                : null,
                            icon: Icon(Icons.save),
                          ),
                          IconButton(
                            onPressed: snapshot.data != KeepState.deleted
                                ? () => store.markAs(music, KeepState.deleted)
                                : null,
                            icon: Icon(Icons.delete_forever),
                          ),
                          _uploadIconButton(catalog, store, toDisplay),
                        ],
                      );
                    }),
              );
            }
          },
        );
      }),
    );
  }

  Widget _uploadIconButton(
    Catalog catalog,
    StateStore store,
    MusicFolder toDisplay,
  ) =>
      IconButton(
          icon: Icon(Icons.upload),
          onPressed: () async {
            final musics = toDisplay.allDescendants;
            await store.exportState(musics);
            await store.discardState(musics);
            await catalog.markAsExported(musics);
          });
}
