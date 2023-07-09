import 'package:flutter/widgets.dart';

import 'music.dart';
import 'music_folder.dart';

/// Catalog that can lists all musics under the root directory provided by [RootFolderNotifier].
/// Refreshes automatically on creation & when [RootFolderNotifier] changes.
mixin Catalog on ChangeNotifier {
  /// List of all musics in the configured root folder,
  /// Includes the musics that were exported already
  List<Music> get allMusics;

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
