import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pref/pref.dart';

/// Notifier wrapped around a stream
class NullableStreamNotifier<Type> extends ChangeNotifier {
  final Stream<Type> stream;
  late final StreamSubscription<Type> _subscription;

  Type? _value;

  /// Subclasses can access this value, and expose it/transform it.
  @protected
  Type? get value => _value;

  NullableStreamNotifier({
    required this.stream,
    required Type? initialValue,
  }) : _value = initialValue {
    _subscription = stream.listen((event) {
      if (_value != event) {
        _value = event;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }
}

/// Notifier wrapped around a stream.
/// Type is not nullable, and it must have an initial value.
class NonNullableStreamNotifier<Type extends Object>
    extends NullableStreamNotifier<Type> {
  /// Subclasses can access this value, and expose it/transform it.
  @protected
  @override
  Type get value => super.value!;

  NonNullableStreamNotifier({
    required super.stream,
    required Type initialValue,
  }) : super(initialValue: initialValue);
}

/// Notifier that wraps around a shared preference key
class NullablePrefNotifier<Type> extends NullableStreamNotifier<Type> {
  NullablePrefNotifier({
    required this.prefService,
    required this.prefName,
  }) : super(
            stream: prefService.stream<Type>(prefName),
            initialValue: prefService.get<Type>(prefName));

  final BasePrefService prefService;
  final String prefName;

  @protected
  set value(Type? newValue) {
    if (_value != newValue) {
      if (newValue == null) {
        prefService.remove(prefName);
      } else {
        prefService.set(prefName, newValue);
      }
    }
    debugPrint("${prefService.getKeys()}, ${prefService.get<Type>(prefName)}");
  }
}

/// Notifier that wraps around a shared preference key
/// Type is not nullable, and it must have an default value setup in the preferences.
class NonNullablePrefNotifier<Type extends Object>
    extends NonNullableStreamNotifier<Type> {
  NonNullablePrefNotifier({
    required this.prefService,
    required this.prefName,
  }) : super(
            stream: prefService.stream<Type>(prefName),
            initialValue: prefService.get<Type>(prefName)!);

  final BasePrefService prefService;
  final String prefName;

  @protected
  set value(Type newValue) {
    if (_value != newValue) {
      prefService.set(prefName, newValue);
    }
    debugPrint("${prefService.getKeys()}, ${prefService.get<Type>(prefName)}");
  }
}
