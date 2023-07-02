import 'dart:io';

import 'package:flutter/widgets.dart';

import 'music.dart';

mixin Catalog on ChangeNotifier {
  /// Loads the given musics into the store.
  /// Clears the previous list from the store.
  /// The loaded musics are yielded by [allMusics]
  Future<void> scan(Directory root);

  /// This simply populates the store using cached state from disk.
  /// Does not re-scan the folder at root.
  Future<void> refresh(String root);

  List<Music> get allMusics;

  MusicFolder? get hierarchy;
}
