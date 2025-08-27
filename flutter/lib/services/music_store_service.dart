import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

import '../data/entities/music.dart';
import '../data/enums/state.dart';
import '../data/models/music_folder.dart';

class MusicStoreService {
  static const String tag = "MusicStoreService";

  final Isar db;
  final IsarCollection<Music> musics;

  MusicStoreService(this.db) : musics = db.musics;

  /// Empties out the entire Music table
  Future<void> clear() async {
    await musics.where().deleteAll();
  }

  Future<void> deleteTreatedMusicsFromFileStorage(Directory root) async {
    final toDelete = await musics.where().stateNotEqualTo(KeepState.unspecified).findAll();

    final futures = <Future<void>>[];
    for (var m in toDelete) {
      final file = File(p.join(root.path, m.path));
      futures.add(file.delete());
    }
    await Future.wait(futures);
    await musics.deleteAll(toDelete.map((m) => m.id).toList());

    final directoriesToCheck = <String>{};
    directoriesToCheck.addAll(toDelete.map((m) => m.parentPath));

    while (directoriesToCheck.isNotEmpty) {
      final path = directoriesToCheck.last;
      directoriesToCheck.remove(path);
      final d = Directory(p.join(root.path, path));
      if (!(await d.exists()) || await d.list(recursive: false, followLinks: false).isEmpty) {
        await d.delete();
        directoriesToCheck.add(d.parent.path);
      }
    }
  }

  Future<MusicFolderDto> getAll(KeepState? state) async {
    // must be dynamic b/c of optional stateEqualTo call
    dynamic query = musics.where();
    if (state != null) {
      query = query.stateEqualTo(state);
    }

    final allPersisted = await query.sortByPath().findAll();
    return _buildMusicHierarchy(allPersisted);
  }

  /// Persist the music changes to the DB
  Future<void> save(Music music) async {
    await musics.put(music);
  }

  /// Scans the given folder and populates the DB with the scanned musics
  Future<void> scanFolder(Directory root) async {
    debugPrint("[$tag]: Rescanning $root...");
    final scanned = <Music>[];
    await _scan(scanned, '', root);
    debugPrint("[$tag]: Scanned ${scanned.length} musics.");

    var added = 0;
    await db.writeTxn(() async {
      final existing = { for (var m in await musics.where().findAll()) m.path };

      for (var m in scanned) {
        if (!existing.contains(m.path)) {
          await musics.put(m);
          added += 1;
        }
      }
    });
    debugPrint("[$tag]: Added $added musics to DB (not yet tracked).");
  }

  MusicFolderDto _buildMusicHierarchy(List<Music> musics) {
    final root = MusicFolderDto(path: '');
    for (var m in musics) {
      final parent = _lookupOrCreate(root, '', m.parentPath.split('/'), 0);
      parent.musics.add(m);
    }
    return root;
  }

  MusicFolderDto _lookupOrCreate(MusicFolderDto parent, String prefix, List<String> splits, int depth) {
    if (depth >= splits.length) {
      return parent;
    }

    final key = splits[depth];
    prefix = p.join(prefix, key);
    final child = parent.children.putIfAbsent(key, () => MusicFolderDto(path: prefix, parent: parent));
    return _lookupOrCreate(child, prefix, splits, depth + 1);
  }

  Future<void> _scan(
    List<Music> scanned,
    String basePath,
    Directory folder,
  ) async {
    final futures = <Future<void>>[];

    await for (var e in folder.list(recursive: false, followLinks: false)) {
      final name = p.basename(e.path);
      final path = p.join(basePath, name);
      if (e is Directory) {
        futures.add(_scan(scanned, path, e));
      } else if (e is File) {
        futures.add(_fetchTags(e, path).then((music) {
          if (music != null) {
            scanned.add(music);
          } else {
            debugPrint("[$tag]: Failed to scan metadata of $path.");
          }
        }));
      }
    }

    await Future.wait(futures);
  }

  Future<Music?> _fetchTags(File file, String path) async {
    try {
      final metadata =
          await MetadataRetriever.fromFile(file).timeout(Duration(seconds: 5));
      return Music(
        path: path,
        title: metadata.trackName,
        artists: (metadata.trackArtistNames?.map((e) => e.toString()) ?? []).join('; '),
        album: metadata.albumName,
        albumArtist: metadata.albumArtistName,
      );
    } catch (e) {
      debugPrint("[$tag]_fetchTag($path) caught error: $e");
      return null;
    }
  }
}
