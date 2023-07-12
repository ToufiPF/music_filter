import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/state_store.dart';
import 'context_menu.dart';

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

  bool get canGoUp => path.isNotEmpty && path != '.';

  void goUp() => setState(() {
        path = Directory(path).parent.path;
      });

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (canGoUp) {
            goUp();
            return false;
          }
          return true;
        },
        child: Consumer<StateStore>(builder: (builder, store, child) {
          final root = store.openFoldersHierarchy;
          final toDisplay = root.lookup(path)!;
          debugPrint("$path - ${toDisplay.debugToString()}");
          return SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: Text(path),
                  leading: IconButton(
                    icon: Icon(Icons.drive_folder_upload),
                    onPressed: canGoUp ? () => goUp() : null,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount:
                      toDisplay.children.length + toDisplay.musics.length,
                  itemBuilder: (context, idx) {
                    if (idx < toDisplay.children.length) {
                      final folder = toDisplay.children[idx];
                      return ListTile(
                        title: Text(folder.folderName),
                        onTap: () => setState(() => path = folder.path),
                        trailing:
                            IconActions.exportActionFolder(context, folder),
                      );
                    } else {
                      idx -= toDisplay.children.length;
                      final music = toDisplay.musics[idx];
                      return ListTile(
                        title: Text(music.title ?? music.filename),
                        trailing: StreamBuilder<KeepState>(
                            initialData: KeepState.unspecified,
                            stream:
                                store.watchState(music, fireImmediately: true),
                            builder: (context, snapshot) {
                              final state = snapshot.data!;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconActions.keptMusicAction(
                                      context, music, state),
                                  IconActions.deleteMusicAction(
                                      context, music, state),
                                  IconActions.exportActionMusic(
                                      context, music, state),
                                ],
                              );
                            }),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }),
      );
}
