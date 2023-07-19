import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pref/pref.dart';

/// Available tabs that can be displayed in the navigation bar
enum AvailableTab {
  folder(
    id: "folder",
    label: "Folder",
    appBarTitle: "Folder view",
    iconDefault: Icons.folder_outlined,
    iconSelected: Icons.folder,
    alwaysActive: false,
  ),
  queue(
    id: "queue",
    label: "Current",
    appBarTitle: "Current queue",
    iconDefault: Icons.queue_music_outlined,
    iconSelected: Icons.queue_music,
    alwaysActive: false,
  ),
  settings(
    id: "settings",
    label: "Settings",
    appBarTitle: "Settings",
    iconDefault: Icons.settings_outlined,
    iconSelected: Icons.settings,
    alwaysActive: true,
  );

  /// Get a [AvailableTab] from its String identifier
  static AvailableTab? fromId(String id) {
    for (var tab in AvailableTab.values) {
      if (tab.id == id) {
        return tab;
      }
    }
    return null;
  }

  const AvailableTab({
    required this.id,
    required this.label,
    required this.appBarTitle,
    required this.iconDefault,
    required this.iconSelected,
    required this.alwaysActive,
  });

  /// Identifier of the tab (for in-code use)
  final String id;

  /// Display name of the tab
  final String label;

  /// Title to display in appBar
  final String? appBarTitle;

  /// Icon to display when tab is not selected
  final IconData iconDefault;

  /// Icon to display when tab is selected
  final IconData iconSelected;

  /// Whether the tab can be hidden
  final bool alwaysActive;
}

List<AvailableTab> decodeAvailableTabs(String jsonStr) {
  final List<(String, bool)> active = _decodeFromJson(jsonStr);
  return active
      .where((e) => e.$2)
      .map((e) => AvailableTab.fromId(e.$1))
      .whereNotNull()
      .toList(growable: false);
}

List<(String, bool)> _decodeFromJson(String jsonStr) {
  Map<String, dynamic> map = jsonDecode(jsonStr);
  final tabs = (map['tabs']! as List<dynamic>).cast<String>();
  final enabled = (map['enabled'] as List<dynamic>).cast<bool>();
  assert(tabs.length == enabled.length);
  return List.generate(tabs.length, (i) => (tabs[i], enabled[i]));
}

String _encodeToJson(List<(String, bool)> tabs) => jsonEncode({
      'tabs': tabs.map((e) => e.$1).toList(growable: false),
      'enabled': tabs.map((e) => e.$2).toList(growable: false),
    });

class PrefActiveTabs extends StatefulWidget {
  static const String tag = "PrefActiveTabs";

  const PrefActiveTabs({
    super.key,
    required this.pref,
    this.title,
    this.subtitle,
    this.onChange,
    this.disabled,
    this.submit,
    this.cancel,
  });

  /// Holds which tab is active
  final String pref;

  /// Button title
  final Widget? title;

  /// Button sub-title
  final Widget? subtitle;

  /// Called when the user confirm their changes
  final ValueChanged<List<String>>? onChange;

  /// Disable user interactions
  final bool? disabled;

  /// Submit button
  final Widget? submit;

  /// Cancel button
  final Widget? cancel;

  @override
  State<PrefActiveTabs> createState() => _PrefActiveTabsState();
}

class _PrefActiveTabsState extends State<PrefActiveTabs> {
  static const String tag = PrefActiveTabs.tag;

  @override
  void didChangeDependencies() {
    PrefService.of(context).addKeyListener(widget.pref, _onNotify);
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    PrefService.of(context).removeKeyListener(widget.pref, _onNotify);
    super.deactivate();
  }

  @override
  void reassemble() {
    PrefService.of(context).addKeyListener(widget.pref, _onNotify);
    super.reassemble();
  }

  void _onNotify() {
    setState(() {});
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    final dynamic value = PrefService.of(context).get<dynamic>(widget.pref);
    properties.add(DiagnosticsProperty(
      'pref',
      value,
      description: '${widget.pref} = $value',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final service = PrefService.of(context);
    final activeTabs = _decodeFromJson(service.get<String>(widget.pref)!);
    debugPrint("[$tag]_build: tabs: $activeTabs");

    final disabled =
        widget.disabled ?? PrefDisableState.of(context)?.disabled ?? false;

    return PrefDialogButton(
      disabled: disabled,
      title: widget.title,
      subtitle: widget.subtitle ??
          Text(activeTabs
              .where((e) => e.$2)
              .map((e) => AvailableTab.fromId(e.$1)?.label ?? e.$1)
              .join(", ")),
      dialog: ReorderablePrefDialog(
        pref: widget.pref,
        title: widget.title,
        onlySaveOnSubmit: true,
        cancel: widget.cancel,
        submit: widget.submit,
      ),
    );
  }
}

/// Same as [PrefDialog], but supports reordering
class ReorderablePrefDialog extends PrefDialog {
  static const String tag = "ReorderablePrefDialog";

  const ReorderablePrefDialog({
    super.key,
    required this.pref,
    super.title,
    super.onlySaveOnSubmit,
    super.submit,
    super.cancel,
    super.actions = const [],
// do not dismiss as soon as user changes something ;
// don't store the children here, we'll build them in the dialog
// from the cached (not yet saved) preferences
  }) : super(children: const [], dismissOnChange: false);

  final String pref;

  @override
  PrefDialogState createState() => ReorderablePrefDialogState();
}

/// The [ReorderablePrefDialog] State
class ReorderablePrefDialogState extends PrefDialogState {
  static const String tag = ReorderablePrefDialog.tag;

  @override
  ReorderablePrefDialog get widget => super.widget as ReorderablePrefDialog;

  /// Builds item dialog from the current preferences (could be cached)
  List<Widget> _buildDialogItems(BuildContext context) {
    final service = PrefService.of(context);
    final activeTabs = _decodeFromJson(service.get<String>(widget.pref)!);

    debugPrint("[$tag]_buildDialogItems: tabs: $activeTabs");

    const colorActive = Colors.blueAccent;
    const colorDefault = Colors.grey;

    List<Widget> children = [];
    for (var (idx, (tabId, isActive)) in activeTabs.indexed) {
      final tab = AvailableTab.fromId(tabId)!;
      children.add(ListTile(
        key: Key(tab.id),
        title: Text(tab.label),
        tileColor: isActive ? Colors.white60 : Colors.white30,
        leading: Icon(
          isActive ? tab.iconSelected : tab.iconDefault,
          color: isActive ? colorActive : colorDefault,
          size: 40,
        ),
        trailing: tab.alwaysActive
            ? null
            : ReorderableDragStartListener(
                index: idx,
                child: Icon(Icons.drag_handle),
              ),
        onTap: tab.alwaysActive
            ? null
            : () {
                activeTabs[idx] = (tabId, !isActive);
                service.set(widget.pref, _encodeToJson(activeTabs));
                setState(() {});
              },
        onLongPress: null,
        enabled: !tab.alwaysActive,
      ));
    }
    return children;
  }

  @override
  Widget buildChild(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color draggableItemColor = colorScheme.secondary;

    Widget proxyDecorator(
            Widget child, int index, Animation<double> animation) =>
        AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (BuildContext context, Widget? child) {
              final double animValue =
                  Curves.easeInOut.transform(animation.value);
              final double elevation = lerpDouble(0, 6, animValue)!;
              return Material(
                elevation: elevation,
                color: draggableItemColor,
                shadowColor: draggableItemColor,
                child: child,
              );
            });

    final actions = <Widget>[...widget.actions];
    _extendActions(actions);

    final service = PrefService.of(context);

    return AlertDialog(
      title: widget.title,
// ignore: sized_box_for_whitespace
      content: Container(
        width: double.maxFinite,
        child: ReorderableListView(
// ignore: sort_child_properties_last
          children: _buildDialogItems(context),
          buildDefaultDragHandles: false,
          proxyDecorator: proxyDecorator,
          shrinkWrap: true,
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }

// Settings must always be the last tab
            if (newIndex == AvailableTab.values.length - 1) {
              debugPrint(
                  "[$tag]_onReorder blocked: old=$oldIndex, new=$newIndex.");
              return;
            }

            final activeTabs =
                _decodeFromJson(service.get<String>(widget.pref)!);

            final pair = activeTabs.removeAt(oldIndex);
            activeTabs.insert(newIndex, pair);
            debugPrint(
                "[$tag]_onReorder: old=$oldIndex, new=$newIndex, $activeTabs saved to $service");
            service.set(widget.pref, _encodeToJson(activeTabs));
            setState(() {});
          },
        ),
      ),
      actions: actions,
    );
  }

  /// copied from [PrefDialogState]
  void _extendActions(List<Widget> actions) {
    if (widget.cancel != null && widget.cache) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: widget.cancel!,
        ),
      );
    }

    if (widget.submit != null) {
      actions.add(
        TextButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            await apply();
            navigator.pop(true);
          },
          child: widget.submit!,
        ),
      );
    }
  }
}
