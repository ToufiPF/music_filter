import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Available permissions for the app
enum PermissionGroup {
  /// On Android < 11: Permission.storage ;
  /// >= 11: Permission.audio + Permission.manageExternalStorage
  storage,

  /// Permission.notification
  notif;
}

enum PermissionStatus {
  /// Permission has been permanently denied
  permanentlyDenied,

  /// Permission is not granted
  denied,

  /// Permission granted
  granted;
}

class PermissionsNotifier extends ChangeNotifier with WidgetsBindingObserver {
  static const String tag = "PermissionsNotifier";
  static const int _androidTiramisuSdkInt = 33;

  /// Open the app settings
  static Future<bool> openSettings() => ph.openAppSettings();

  static Future<PermissionsNotifier> initialize() async {
    bool isAndroidQ = false;
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      isAndroidQ = info.version.sdkInt >= _androidTiramisuSdkInt;
    }

    return PermissionsNotifier._(isAndroidQ);
  }

  /// Holds status of each permission type
  final _statuses = <PermissionGroup, PermissionStatus>{};

  /// Whether to use the android Q storage permissions
  final bool isAndroidTiramisu;

  PermissionsNotifier._(this.isAndroidTiramisu) {
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
    final statuses = <PermissionStatus>[];
    for (var t in permissions) {
      final res = await _getPermissionsFor(t).request();
      statuses.add(_reduceAll(res.values.toList(growable: false)));
    }
    await _updateInternal(Map.fromIterables(permissions, statuses));
  }

  /// Requests for the given permissions, and go to settings if permission is permanently denied
  /// Page calling this method needs to manually refresh the permissions when it resumes
  Future<void> requestOrGoToSettings(List<PermissionGroup> permissions) async {
    final statuses = <PermissionStatus>[];
    for (var t in permissions) {
      final res = await _getPermissionsFor(t).request();
      statuses.add(_reduceAll(res.values.toList(growable: false)));
    }
    if (statuses.any((e) => e == PermissionStatus.permanentlyDenied)) {
      var ok = await openSettings();
      if (!ok) {
        debugPrint("[$tag]_requestOrGoToSettings: failed to launch settings");
      }
    }
    await _updateInternal(Map.fromIterables(permissions, statuses));
  }

  /// Refresh the status of all permissions
  Future<void> refreshStatus() async {
    const permissions = PermissionGroup.values;
    final statuses = <PermissionStatus>[];
    for (var t in permissions) {
      final res = await Future.wait(_getPermissionsFor(t).map((p) => p.status));
      statuses.add(_reduceAll(res));
    }
    await _updateInternal(Map.fromIterables(permissions, statuses));
  }

  Future<void> _updateInternal(
      Map<PermissionGroup, PermissionStatus> permissions) async {
    debugPrint('[$tag]_updateInternal($permissions)');

    bool shouldNotify = false;
    for (var entry in permissions.entries) {
      PermissionStatus? oldStatus = _statuses[entry.key];
      PermissionStatus newStatus = entry.value;

      if (oldStatus != newStatus &&
          !(oldStatus == PermissionStatus.permanentlyDenied &&
              newStatus == PermissionStatus.denied)) {
        _statuses[entry.key] = newStatus;
        shouldNotify = true;
      }
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  List<ph.Permission> _getPermissionsFor(PermissionGroup p) => switch (p) {
        // Need manage storage permission to be able to edit files in Music/ folder likes
        PermissionGroup.storage => const [ph.Permission.manageExternalStorage] +
            (isAndroidTiramisu
                ? const [ph.Permission.audio]
                : const [ph.Permission.storage]),
        PermissionGroup.notif => const [ph.Permission.notification],
      };
}

PermissionStatus _reduceAll(List<ph.PermissionStatus> statuses) =>
    statuses.every((e) => e.isGranted)
        ? PermissionStatus.granted
        : statuses.any((e) => e.isPermanentlyDenied)
            ? PermissionStatus.permanentlyDenied
            : PermissionStatus.denied;
