import 'package:flutter/material.dart';

enum KeepState {
  /// default state, never explicitly kept or deleted
  unspecified(Icons.restore),

  /// user marked the music as kept
  kept(Icons.save),

  /// user marked the music as deleted
  deleted(Icons.delete_forever);

  const KeepState(this.icon);

  final IconData icon;

  @override
  String toString() => switch (this) {
        KeepState.kept => "kept",
        KeepState.deleted => "deleted",
        KeepState.unspecified => "unspecified",
      };
}

extension NextState on KeepState {
  KeepState get nextToggleState =>
      KeepState.values[(index + 1) % KeepState.values.length];
}
