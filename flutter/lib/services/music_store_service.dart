import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../data/entities/music.dart';
import '../data/enums/state.dart';
import '../data/models/music_folder.dart';
import '../util/misc.dart';

class MusicStoreService {
  static const String tag = "MusicStoreService";

  final Isar db;
  final IsarCollection<Music> musics;
  final _stream = BehaviorSubject<MusicFolder?>();

  Stream<MusicFolder?> get catalog => _stream.stream;

  MusicStoreService(this.db) : musics = db.musics {
    _refreshStream();
  }

  /// Empties out the entire Music table
  Future<void> clear() async {
    await musics.where().deleteAll();
    _stream.add(null);
  }

  Future<int?> exportTreatedMusicStates(File file) async {
    IOSink? sink;
    try {
      await file.parent.create(recursive: true);
      sink = file.openWrite(mode: FileMode.writeOnlyAppend);

      final toExport = await musics.where().needsExportEqualTo(true).findAll();
      for (var m in toExport) {
        sink.writeln("\"${m.virtualPath.escapeDoubleQuotes()}\", ${m.state}");
        m.needsExport = false;
      }

      await sink.flush();
      await db.writeTxn(() async {
        await musics.putAll(toExport);
      });
      return toExport.length;
    } catch (e) {
      debugPrint(
          "[$tag] Caught exception when exporting music states to ${file.path}");
      return null;
    } finally {
      sink?.close();
    }
  }

  Future<void> deleteTreatedMusicsFromFileStorage(Directory root) async {
    final toDelete =
        await musics.where().stateNotEqualTo(KeepState.unspecified).findAll();

    final futures = <Future<void>>[];
    for (var m in toDelete) {
      final file = File(m.physicalPath);
      futures.add(file.delete());
    }
    await Future.wait(futures);

    await db.writeTxn(() async {
      await musics.deleteAll(toDelete.map((m) => m.id).toList());
    });

    final directoriesToCheck = <String>{};
    directoriesToCheck.addAll(toDelete.map((m) => m.parentPath));

    while (directoriesToCheck.isNotEmpty) {
      final path = directoriesToCheck.last;
      directoriesToCheck.remove(path);
      final d = Directory(p.join(root.path, path));
      if (!(await d.exists()) ||
          await d.list(recursive: false, followLinks: false).isEmpty) {
        await d.delete();
        directoriesToCheck.add(d.parent.path);
      }
    }

    await _refreshStream();
  }

  Future<MusicFolder> getAll(KeepState? state) async {
    final allPersisted = await _getAll(state);
    return MusicFolder.buildMusicHierarchy(allPersisted);
  }

  Future<List<Music>> _getAll(KeepState? state) async {
    // must be dynamic b/c of optional stateEqualTo call
    dynamic query = musics.where();
    if (state != null) {
      query = query.stateEqualTo(state);
    }
    final q = query as QueryBuilder<Music, Music, QSortBy>;
    return await q.sortByPhysicalPath().findAll();
  }

  /// Persist the music changes to the DB
  Future<void> setState(Music music, KeepState state) async {
    await db.writeTxn(() async {
      music.state = state;
      music.needsExport = true;
      await musics.put(music);
    });
  }

  Stream<KeepState> watchState(Music music) {
    return musics
        .watchObjectLazy(music.id, fireImmediately: true)
        .map((_) => music.state)
        .distinct();
    // return musics.watchObject(music.id, fireImmediately: true).map((m) => m?.state ?? KeepState.unspecified);
  }

  /// Scans the given folder and populates the DB with the scanned musics
  Future<void> scanFolder(Directory root) async {
    debugPrint("[$tag]: Rescanning $root...");
    final scanned = <Music>[];
    await _scan(scanned, '', root);
    debugPrint("[$tag]: Scanned ${scanned.length} musics.");

    var added = 0;
    await db.writeTxn(() async {
      final existing = {
        for (var m in await musics.where().findAll()) m.physicalPath
      };

      for (var m in scanned) {
        if (existing.add(m.physicalPath)) {
          await musics.put(m);
          added += 1;
        }
      }
    });
    debugPrint("[$tag]: Added $added musics to DB (not yet tracked).");

    await _refreshStream();
  }

  Future<void> _refreshStream() async {
    final newState = await getAll(null);
    _stream.add(newState);
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
          await MetadataRetriever.fromFile(file).timeout(Duration(seconds: 50));
      return Music(
        physicalPath: file.path,
        virtualPath: path,
        title: metadata.trackName,
        artists: (metadata.trackArtistNames?.map((e) => e.toString()) ?? [])
            .join('; '),
        album: metadata.albumName,
        albumArtist: metadata.albumArtistName,
      );
    } catch (e) {
      debugPrint("[$tag]_fetchTag(${file.path}) caught error: $e");
      return null;
    }
  }
}
