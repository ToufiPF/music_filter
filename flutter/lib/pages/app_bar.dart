import 'package:flutter/material.dart';

import '../settings/active_tabs.dart';

class AppBarUtils {
  static Widget settingsAction(BuildContext context) => IconButton(
        onPressed: () => Navigator.of(context).pushNamed("settings"),
        icon: Icon(AvailableTab.settings.iconSelected),
      );

  AppBarUtils._();
}
