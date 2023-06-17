import '../settings/active_tabs.dart';
import '../settings/settings.dart';
import '_base.dart';

/// Exposes the list of Tab to display
class ActiveTabsNotifier extends NonNullablePrefNotifier<String> {
  ActiveTabsNotifier({required super.prefService})
      : super(prefName: Pref.activeTabs.name);

  /// List of tabs to display
  List<AvailableTab> get tabs =>
      decodeAvailableTabs(super.value).toList(growable: false);
}
