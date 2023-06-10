import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pref/pref.dart';

import 'active_tabs.dart';

enum Pref {
  /// Tracks which tabs are displayed in the nav bar
  activeTabs("active_tabs", null),
  ;

  /// Returns the default values for each preference
  static Map<String, dynamic> getDefaultValues() =>
      {for (var pref in Pref.values) pref.name: pref.defaultValue};

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
        // ignore: unreachable_switch_case
        _ => _defaultValue,
      };
}

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: PrefPage(
          children: [
            const PrefTitle(title: Text('General')),
            PrefActiveTabs(
              pref: Pref.activeTabs.name,
              submit: Text("Ok"),
              cancel: Text("Cancel"),
            ),
          ],
        ),
      );
}
