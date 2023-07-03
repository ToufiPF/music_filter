import 'package:flutter/widgets.dart';

import 'music.dart';

/// Stores & exposes the hierarchy of musics
mixin Hierarchy on ChangeNotifier {
  /// Hierarchy of the musics that have yet to be filtered
  MusicFolder? get toFilter;

  /// Hierarchy of the musics that were filtered already,
  /// they should not be shown in e.g. FileView
  MusicFolder? get recycleBin;

  /// Returns the [MusicFolder] that is the direct parent of this music
  MusicFolder? getParent(Music music);

  /// Moves the given musics to the recycleBin.
  /// Creates [MusicFolder] in the recycleBin if they do not exist
  /// and deletes empty [MusicFolder]s from [toFilter]
  Future<void> markAsExported(Iterable<Music> musics);

  /// Reverse [markAsExported]
  Future<void> restore(Iterable<Music> musics);
}
