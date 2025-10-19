import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

import '../services/music_store_service.dart';
import '_base.dart';

class RootFolderNotifier extends NullablePrefNotifier<String> {
  static const String tag = "RootFolderNotifier";

  final MusicStoreService store;

  RootFolderNotifier(
      {required super.prefService,
      required super.prefName,
      required this.store});

  /// Returns the path to the configured folder
  Directory? get rootFolder =>
      super.value != null ? Directory(super.value!) : null;

  File? get exportFile =>
      rootFolder != null ? File(p.join(rootFolder!.path, 'export.csv')) : null;

  Future<bool> pickFolder(Directory? initialDir) async {
    String? picked = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Chose a folder",
      lockParentWindow: true,
      initialDirectory: initialDir?.path,
    );

    debugPrint("[$tag]_pickFolder: user picked $picked");
    if (picked == null) {
      return false;
    }

    super.value = picked;
    await store.clear();
    await store.scanFolder(Directory(picked));
    return true;
  }

  Future<void> resetFolder() async {
    debugPrint("[$tag]_resetFolder: dropping ${super.value}");
    super.value = null;
    await store.clear();
  }
}
