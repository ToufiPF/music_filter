import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/playlist_service.dart';

class RemoveTreatedMusicsFromPlaylistButton extends StatelessWidget {
  final double iconSize;

  const RemoveTreatedMusicsFromPlaylistButton({super.key, required this.iconSize});

  @override
  Widget build(BuildContext context) => IconButton(
      icon: Icon(Icons.bookmark_remove_outlined, size: iconSize),
      onPressed: () async {
        final playlist = Provider.of<PlaylistService>(context, listen: false);
        await playlist.removeTreatedMusics();
      });
}
