import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog.dart';

class RecycleBinView extends StatefulWidget {
  const RecycleBinView({super.key});

  @override
  State<StatefulWidget> createState() => _RecycleBinViewState();
}

class _RecycleBinViewState extends State<RecycleBinView> {

  @override
  Widget build(BuildContext context) =>
      Consumer<Catalog>(
        builder: (context, catalog, child) {
          final recycleRoot = catalog.recycleBin;
          final musics = recycleRoot?.allDescendants ?? [];
          return ListView.builder(
              itemCount: musics.length,
              itemBuilder: (context, idx) =>
                  ListTile(
                    title: Text(musics[idx].filename),
                  ));
        },
      );
}
