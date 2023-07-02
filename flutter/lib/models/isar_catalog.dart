import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

import 'catalog.dart';
import 'music.dart';

class IsarCatalog extends ChangeNotifier with Catalog {
  static const tag = "IsarCatalog";

  IsarCatalog({required Isar isarDb}) : _musics = isarDb.musics;

  final IsarCollection<Music> _musics;

  List<Music> _musicsCache = [];
  MusicFolder? _hierarchy;

  @override
  List<Music> get allMusics => _musicsCache.toList(growable: false);

  @override
  MusicFolder? get hierarchy => _hierarchy;

  @override
  Future<void> scan(Directory root) async {
    debugPrint("[$tag]: Scanning $root...");
    final musics = await _scanForMusics(root).toList();

    await _musics.isar.writeTxn(() async {
      await _musics.clear();
      await _musics.putAll(musics);
    });
    debugPrint("[$tag]: Scanning done: Found ${musics.length} musics");

    _refreshCache(root.path, musics);
  }

  @override
  Future<void> refresh(String root) => _refreshCache(root);

  Future<void> _refreshCache(String root, [List<Music>? musics]) async {
    musics ??= await _musics.where().findAll();
    _musicsCache = musics;

    var newRoot = MusicFolder(path: root, parent: null);
    _populateHierarchy(newRoot, musics);
    _hierarchy = newRoot;
    notifyListeners();
  }
}

void _populateHierarchy(MusicFolder root, List<Music> musics) {
  final cache = <String, MusicFolder>{};
  for (var music in musics) {
    final path = p.relative(music.path, from: root.path);
    MusicFolder folder = root;
    var part = "";
    for (var split in p.split(p.dirname(path))) {
      part = p.join(part, split);
      folder = cache.putIfAbsent(part, () {
        var tmp = MusicFolder(path: p.join(root.path, part), parent: folder);
        folder.folders.add(tmp);
        return tmp;
      });
    }
    debugPrint("${music.path} -> $part, $folder");
    folder.musics.add(music);
  }
}

Stream<Music> _scanForMusics(Directory root) async* {
  await for (var file in root.list(recursive: true, followLinks: false)) {
    if (file is File) {
      final music = await _fetchTags(file);
      if (music != null) {
        yield music;
      } else {
        debugPrint("[_scanForMusics]: Skipped file $file");
      }
    }
  }
}

Future<Music?> _fetchTags(File file) async {
  final metadata = await MetadataRetriever.fromFile(file);
  return Music(
    path: file.path,
    title: metadata.trackName,
    artists: metadata.trackArtistNames ?? [],
    album: metadata.albumName,
    albumArtist: metadata.albumArtistName,
  );
}
