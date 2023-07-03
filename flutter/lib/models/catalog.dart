import 'package:flutter/widgets.dart';

import 'music.dart';

/// Catalog that can lists all musics under the root directory provided by [RootFolderNotifier].
/// Refreshes automatically on creation & when [RootFolderNotifier] changes.
mixin Catalog on ChangeNotifier {
  /// List of all musics in the configured root folder,
  /// Includes the musics that were exported already
  List<Music> get allMusics;
}
