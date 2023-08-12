import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog.dart';
import '../models/state_store.dart';

class RecycleBinView extends StatelessWidget {
  const RecycleBinView({super.key});

  @override
  Widget build(BuildContext context) => Consumer<Catalog>(
        builder: (context, catalog, child) {
          final recycleRoot = catalog.recycleBin;
          final store = Provider.of<StateStore>(context, listen: false);

          final musics = recycleRoot?.allDescendants ?? [];
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: musics.length,
              itemBuilder: (context, idx) => ListTile(
                    title: Text(musics[idx].filename),
                    leading: FutureBuilder<KeepState>(
                      initialData: KeepState.unspecified,
                      future: null, // TODO get KeepState of recycled music
                      builder: (context, snapshot) => Icon(snapshot.data!.icon),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.restore),
                      onPressed: () async {
                        final music = musics[idx];
                        await store.markAs(music, KeepState.unspecified);
                        await store.exportState([music]);
                        await catalog.restore([music]);
                      },
                    ),
                  ));
        },
      );
}
