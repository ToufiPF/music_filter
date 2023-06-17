import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/root_folder.dart';
import '../widget/file_view.dart';

/// Home page for the app
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.inversePrimary,
          title: Text(MyApp.title),
          actions: [],
        ),
        body: Center(
          child: Consumer<RootFolderNotifier>(
            builder: (context, provider, child) => provider.rootFolder != null
                ? FileView(root: provider.rootFolder!)
                : ElevatedButton(
                    onPressed: () => provider.pickFolder(null),
                    child: Text("Chose a folder")),
          ),
        ));
  }
}
