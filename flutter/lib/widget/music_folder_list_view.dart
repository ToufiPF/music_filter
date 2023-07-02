import 'package:flutter/material.dart';

import '../models/music.dart';
import 'music_list_view.dart';

class MusicFolderListView extends StatefulWidget {
  const MusicFolderListView({super.key, required this.folders});

  final List<MusicFolder> folders;

  @override
  State<MusicFolderListView> createState() => _MusicFolderListViewState();
}

class _MusicFolderListViewState extends State<MusicFolderListView> {
  MusicFolder? shownContent;

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        if (shownContent != null) {
          setState(() => shownContent = null);
          return false;
        }
        return true;
      },
      child: shownContent == null
          ? ListView.builder(
              itemCount: widget.folders.length,
              itemBuilder: (context, idx) {
                final folder = widget.folders[idx];
                return ListTile(
                  title: Text(folder.folderName),
                  leading: Icon(Icons.folder_outlined),
                  onTap: () => setState(() => shownContent = folder),
                );
              },
            )
          : MusicListView(
              musics: shownContent!.musics,
              popupActions: [],
              onSelected: (context, musicIdx, action) {},
            ));
}
