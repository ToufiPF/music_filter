import 'package:flutter/material.dart';

import '../models/music.dart';
import 'context_menu.dart';

typedef OnMenuActionSelected = void Function(
    BuildContext context, int musicIdx, MenuAction selectedAction);

class MusicListView extends StatelessWidget {
  const MusicListView({
    super.key,
    required this.musics,
    required this.popupActions,
    required this.onSelected,
  });

  final List<MenuAction> popupActions;
  final OnMenuActionSelected onSelected;

  final List<Music> musics;

  @override
  Widget build(BuildContext context) => ListView.builder(
      itemCount: musics.length,
      itemBuilder: (context, idx) {
        final music = musics[idx];
        return ListTile(
          title: Text(music.title ?? music.filename),
          subtitle: Text("${music.displayArtist}\n${music.path}"),
          isThreeLine: true,
          trailing: PopupMenuButton<int>(
            child: Icon(Icons.more_vert, size: 32),
            itemBuilder: (context) => [
              for (var action in popupActions)
                PopupMenuItem<int>(
                    value: action.index, child: Text(action.text)),
            ],
            onSelected: (actionIdx) =>
                onSelected(context, idx, MenuAction.values[actionIdx]),
          ),
        );
      });
}
