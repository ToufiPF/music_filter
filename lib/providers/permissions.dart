import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Available permissions for the app
enum PermissionGroup {
  storage(ph.Permission.storage),
  notif(ph.Permission.notification),
  media(ph.Permission.audio);

  const PermissionGroup(this._perm);

  final ph.Permission _perm;
}

enum PermissionStatus {
  /// Permission has been permanently denied
  permanentlyDenied,

  /// Permission is not granted
  denied,

  /// Permission granted
  granted;

  static PermissionStatus _from(ph.PermissionStatus status) => status.isGranted
      ? PermissionStatus.granted
      : status.isPermanentlyDenied
          ? PermissionStatus.permanentlyDenied
          : PermissionStatus.denied;
}

class PermissionsNotifier extends ChangeNotifier with WidgetsBindingObserver {
  static const String tag = "PermissionsNotifier";

  /// Open the app settings
  static Future<bool> openSettings() => ph.openAppSettings();

  /// Holds status of each permission type
  final _statuses = <PermissionGroup, PermissionStatus>{};

  PermissionsNotifier() {
    refreshStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("[$tag]_didChangeAppLifecycleState: refreshing");
        refreshStatus();
        break;
      default:
        break;
    }
  }

  /// Returns the status for the given permission
  PermissionStatus getStatus(PermissionGroup permission) =>
      _statuses[permission] ?? PermissionStatus.denied;

  /// Returns the statuses for the given permissions, in the same order
  List<PermissionStatus> getStatuses(Iterable<PermissionGroup> permissions) =>
      permissions.map((e) => getStatus(e)).toList(growable: false);

  /// Requests for the given permissions,
  /// automatically refreshes status afterwards.
  Future<void> requestPermissions(List<PermissionGroup> permissions) async {
    final perms = <PermissionStatus>[];
    for (var t in permissions) {
      perms.add(PermissionStatus._from(await t._perm.request()));
    }
    await _updateInternal(permissions, perms);
  }

  /// Requests for the given permissions, and go to settings if permission is permanently denied
  /// Page calling this method needs to manually refresh the permissions when it resumes
  Future<void> requestOrGoToSettings(List<PermissionGroup> permissions) async {
    final perms = <PermissionStatus>[];
    for (var t in permissions) {
      perms.add(PermissionStatus._from(await t._perm.request()));
    }
    if (perms.any((e) => e == PermissionStatus.permanentlyDenied)) {
      var ok = await openSettings();
      if (!ok) {
        debugPrint("[$tag]_requestOrGoToSettings: failed to launch settings");
      }
    }
    await _updateInternal(permissions, perms);
  }

  /// Refresh the status of all permissions
  Future<void> refreshStatus() async {
    final perms = <PermissionStatus>[];
    for (var t in PermissionGroup.values) {
      perms.add(PermissionStatus._from(await t._perm.status));
    }
    await _updateInternal(PermissionGroup.values, perms);
  }

  Future<void> _updateInternal(
    List<PermissionGroup> types,
    List<PermissionStatus> permissions,
  ) async {
    debugPrint('[$tag]_updateInternal($types) --> $permissions');
    assert(types.length == permissions.length);

    bool shouldNotify = false;
    for (var (idx, type) in types.indexed) {
      PermissionStatus? oldStatus = _statuses[type];
      PermissionStatus newStatus = permissions[idx];

      if (oldStatus != newStatus &&
          !(oldStatus == PermissionStatus.permanentlyDenied &&
              newStatus == PermissionStatus.denied)) {
        _statuses[type] = newStatus;
        shouldNotify = true;
      }
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }
}
