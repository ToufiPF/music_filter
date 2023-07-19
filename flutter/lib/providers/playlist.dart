import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;

import '../misc.dart';
import '../models/music.dart';
import '../providers/root_folder.dart';

/// Controller/Observer of the currently playing queue
mixin PlayerQueueNotifier on ChangeNotifier {
  /// View on the current queue (unmodifiable)
  List<Music> get queue;

  /// Append all musics to the end of the queue
  Future<void> appendAll(Iterable<Music> musics);

  /// Remove all occurrences of the given musics from the queue.
  Future<void> removeAll(Iterable<Music> musics);

  /// Insert a music to the given index
  Future<void> insert(int index, Music music);

  /// Remove the item at the given index from the queue
  Future<void> removeAt(int index);

  /// Moves the music at the given [oldIndex] to the [newIndex]
  /// [newIndex] is the place where the item would be inserted in the original list
  Future<void> move(int oldIndex, int newIndex);

  /// Empties the queue
  Future<void> clear();
}

class JustAudioQueueNotifier extends ChangeNotifier with PlayerQueueNotifier {
  JustAudioQueueNotifier(this.root);

  final ConcatenatingAudioSource _source =
      ConcatenatingAudioSource(children: []);

  /// TODO: use Isar id instead
  var idxCounter = 0;
  final List<Music> _currentQueue = [];
  final RootFolderNotifier root;

  AudioSource get audioSource => _source;

  @override
  List<Music> get queue => _currentQueue.toList(growable: false);

  @override
  Future<void> appendAll(Iterable<Music> musics) async {
    _currentQueue.addAll(musics);
    await _source
        .addAll(musics.map((e) => _musicToSource(e)).toList(growable: false));

    notifyListeners();
  }

  @override
  Future<void> removeAll(Iterable<Music> musics) async {
    final copy = musics.toSet();
    final indices = _currentQueue.indexed
        .where((pair) => copy.contains(pair.$2))
        .map((e) => e.$1)
        .toList(growable: false);

    final ranges = indices.collapseToRanges();
    // because we incrementally delete entries from the queue,
    int cumulatedLength = 0;
    for (var (start, len) in ranges) {
      start -= cumulatedLength;
      _currentQueue.removeRange(start, start + len);
      await _source.removeRange(start, start + len);

      cumulatedLength += len;
    }
    notifyListeners();
  }

  @override
  Future<void> insert(int index, Music music) async {
    _currentQueue.insert(index, music);
    await _source.insert(index, _musicToSource(music));
    notifyListeners();
  }

  @override
  Future<void> removeAt(int index) async {
    _currentQueue.removeAt(index);
    await _source.removeAt(index);
    notifyListeners();
  }

  @override
  Future<void> move(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final music = _currentQueue.removeAt(oldIndex);
    _currentQueue.insert(newIndex, music);
    // TODO test whether to call this before or after decrementing newIndex
    await _source.move(oldIndex, newIndex);
    notifyListeners();
  }

  @override
  Future<void> clear() async {
    _currentQueue.clear();
    await _source.clear();
    notifyListeners();
  }

  AudioSource _musicToSource(Music music) {
    final id = idxCounter.toString();
    idxCounter += 1;
    return AudioSource.file(p.join(root.rootFolder!.path, music.path),
        tag: MediaItem(
          id: id,
          title: music.title ?? music.filename,
          album: music.album,
          artist: music.displayArtist,
        ));
  }
}
