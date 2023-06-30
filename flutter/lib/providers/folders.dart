import '../settings/settings.dart';
import '_base.dart';

class ShowHiddenFilesNotifier extends NonNullablePrefNotifier<bool> {
  ShowHiddenFilesNotifier({required super.prefService})
      : super(prefName: Pref.showHiddenFiles.name);

  bool get show => super.value;
}

class ShowEmptyFoldersNotifier extends NonNullablePrefNotifier<bool> {
  ShowEmptyFoldersNotifier({required super.prefService})
      : super(prefName: Pref.showEmptyFolders.name);

  bool get show => super.value;
}
