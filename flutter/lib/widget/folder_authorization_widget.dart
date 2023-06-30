import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/permissions.dart';
import '../providers/root_folder.dart';

class FolderAuthorizationWidget extends StatefulWidget {
  const FolderAuthorizationWidget({super.key});

  @override
  State<StatefulWidget> createState() => _FolderAuthorizationWidgetState();
}

class _FolderAuthorizationWidgetState extends State<FolderAuthorizationWidget> {
  PermissionStatus storage = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () async {
          final provider =
              Provider.of<RootFolderNotifier>(context, listen: false);
          await provider.pickFolder(null);
        },
        child: Text("Choose root music folder"),
      );
}
