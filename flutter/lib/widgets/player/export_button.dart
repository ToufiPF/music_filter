import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/root_folder.dart';
import '../../services/music_store_service.dart';
import '../../util/toast_helper.dart';

class ExportButtonWidget extends StatelessWidget {
  const ExportButtonWidget({super.key, required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<MusicStoreService>(context, listen: false);

    return Consumer<RootFolderNotifier>(
        builder: (context, rootFolder, child) => IconButton(
            icon: Icon(Icons.import_export),
            onPressed: rootFolder.exportFile != null
                ? () async {
                    final count = await store
                        .exportTreatedMusicStates(rootFolder.exportFile!);

                    ToastHelper.showMessageWithCancel("Exported $count musics");
                  }
                : null));
  }
}
