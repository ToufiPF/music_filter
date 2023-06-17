import 'package:flutter/material.dart';

import '../models/music.dart';

class PlaylistNotifier extends ChangeNotifier {
  final List<Music> _queue = [];

  List<Music> get currentQueue => _queue.toList(growable: false);

  void clear() {
    _queue.clear();
    notifyListeners();
  }

  void appendAll(List<Music> others) {
    _queue.addAll(others);
    notifyListeners();
  }

  void insert(int index, Music other) {
    _queue.insert(index, other);
    notifyListeners();
  }
}
