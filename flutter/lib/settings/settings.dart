import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';

import '../models/catalog.dart';
import '../models/state_store.dart';
import '../providers/root_folder.dart';
import 'active_tabs.dart';

enum Pref {
  /// Tracks which tabs are displayed in the nav bar.
  /// Contains a json encoded String.
  activeTabs("active_tabs", null),

  /// Tracks the directory to explore when searching for musics/presenting the folder view.
  /// Holds a String, the path to the [Directory]
  rootFolder("music_root_folder", null),

  /// Whether to show hidden files in the FileView widget.
  /// Holds a bool.
  showHiddenFiles("show_hidden_folders", false),

  /// Whether to show empty folders in the FileView widget
  /// Holds a bool.
  showEmptyFolders("show_empty_folders", false),
  ;

  /// Returns the default values for each preference
  static Map<String, dynamic> getDefaultValues() => {
        for (var pref in Pref.values)
          if (pref.defaultValue != null) pref.name: pref.defaultValue
      };

  const Pref(this.name, this._defaultValue);

  /// String identifier for the preference
  final String name;

  /// Default value, can have complex type as long as conversion
  /// to a compatible type is done in [defaultValue]
  final dynamic _defaultValue;

  /// Default value of the preferences.
  /// Type can be bool, int, String, List<String> (MUST BE GROWABLE)
  dynamic get defaultValue => switch (this) {
        Pref.activeTabs => jsonEncode({
            'tabs': AvailableTab.values.map((e) => e.id).toList(),
            'enabled': List.generate(AvailableTab.values.length, (i) => true),
          }),
        _ => _defaultValue,
      };
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const PrefTitle(title: Text('General')),
          PrefActiveTabs(
            pref: Pref.activeTabs.name,
            title: Text("Active tabs"),
            submit: Text("Ok"),
            cancel: Text("Cancel"),
          ),
          PrefSwitch(
            pref: Pref.showEmptyFolders.name,
            title: Text("Show empty folders"),
          ),
          PrefSwitch(
            pref: Pref.showHiddenFiles.name,
            title: Text("Show hidden files"),
          ),
          PrefButton(
            child: Text("Restore musics in recycle bin"),
            onTap: () async {
              final catalog = Provider.of<Catalog>(context, listen: false);
              final store = Provider.of<StateStore>(context, listen: false);
              final musics = catalog.recycleBin?.allDescendants ?? [];

              await Future.forEach(
                  musics, (e) => store.markAs(e, KeepState.unspecified));
              await store.exportState(musics);
              await catalog.restore(musics);
            },
          ),
          PrefButton(
            child: Text("Select folder"),
            onTap: () {
              final root =
                  Provider.of<RootFolderNotifier>(context, listen: false);
              root.pickFolder(root.rootFolder);
            },
          ),
        ],
      );
}
