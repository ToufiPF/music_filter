import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path/path.dart' as p;

import '../models/music.dart';
import '../providers/root_folder.dart';

/// Controller/Observer of the currently playing queue
mixin PlayerQueueNotifier on ChangeNotifier {
  /// View on the current queue (unmodifiable)
  List<Music> get queue;

  /// Append all musics to the end of the queue
  Future<void> appendAll(List<Music> musics);

  /// Insert a music to the given index
  Future<void> insert(int index, Music music);

  /// Remove the item at the given index from the queue
  Future<void> removeAt(int index);

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
  Future<void> appendAll(List<Music> musics) async {
    _currentQueue.addAll(musics);
    await _source
        .addAll(musics.map((e) => _musicToSource(e)).toList(growable: false));

    notifyListeners();
  }

  @override
  Future<void> insert(int index, Music music) async {
    _currentQueue.insert(index, music);
    await _source.add(_musicToSource(music));
    notifyListeners();
  }

  @override
  Future<void> removeAt(int index) async {
    _currentQueue.removeAt(index);
    await _source.removeAt(index);
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
