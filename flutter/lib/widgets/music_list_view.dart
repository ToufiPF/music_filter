import 'package:flutter/material.dart';

import '../models/music.dart';

class MusicListView extends StatelessWidget {
  const MusicListView({
    super.key,
    required this.musics,
  });

  final List<Music> musics;

  @override
  Widget build(BuildContext context) => ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: musics.length,
      itemBuilder: (context, idx) {
        final music = musics[idx];
        return ListTile(
          title: Text(music.title ?? music.filename),
          subtitle: Text(music.displayArtist),
          // subtitle: Text("${music.displayArtist}\n${music.path}", maxLines: 2),
          // isThreeLine: false,
          trailing: PopupMenuButton<int>(
            child: Icon(Icons.more_vert, size: 32),
            itemBuilder: (context) => [],
            onSelected: (actionIdx) {},
          ),
        );
      });
}
