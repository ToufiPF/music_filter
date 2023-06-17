import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

import '_base.dart';

class RootFolderNotifier extends NullablePrefNotifier<String> {
  static const String tag = "RootFolderNotifier";

  RootFolderNotifier({required super.prefService, required super.prefName});

  /// Returns the path to the configured folder
  Directory? get rootFolder =>
      super.value != null ? Directory(super.value!) : null;

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
    return true;
  }

  void resetFolder() {
    debugPrint("[$tag]_resetFolder: dropping ${super.value}");
    if (super.value != null) {
      super.value = null;
    }
  }
}
