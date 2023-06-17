import 'package:flutter/widgets.dart';
import 'package:pref/pref.dart';

import '../settings/active_tabs.dart';
import '../settings/settings.dart';

class ActiveTabsNotifier extends ChangeNotifier {
  final BasePrefService service;

  ActiveTabsNotifier(this.service) {
    String str = service.get<String>(Pref.activeTabs.name)!;
    activeTabs = decodeAvailableTabs(str);

    service.stream<String>(Pref.activeTabs.name).listen((str) {
      var newTabs = decodeAvailableTabs(str);
      var newSelectedIndex = newTabs.indexOf(selected);
      activeTabs = newTabs;
      _activeIndex = newSelectedIndex != -1 ? newSelectedIndex : 0;
      notifyListeners();
    });
  }

  late List<AvailableTab> activeTabs;

  int _activeIndex = 0;

  int get activeIndex => _activeIndex;

  AvailableTab get selected => activeTabs[_activeIndex];

  set activeIndex(int newValue) {
    if (_activeIndex != newValue) {
      _activeIndex = newValue;
      notifyListeners();
    }
  }
}
