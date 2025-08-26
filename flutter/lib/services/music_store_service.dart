import 'dart:io';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as p;

import 'data/entities/music.dart';

class MusicStoreService {
  static const String tag = "MusicStoreService";

  final Db db;
  final DbSet<Music> musics;

  MusicStoreService(this.db) {
    this.musics = this.db.musics;
  }

  /// Empties out the entire Music table
  Future<void> clear() async {
    await this.musics.clear();
  }

  Future<void> deleteTreatedMusicsFromFileStorage(Directory root) async {
    final toDelete = await this.musics.where(m => m.state != KeepState.unspecified).getAll();

    final futures = <Future<void>>[];
    await for (var m in toDelete) {
      final file = new File(root, m.path);
      futures.add(file.delete());
    }
    await Future.wait(futures);
    await this.musics.deleteAll(toDelete);

    final directoriesToCheck = new HashSet<String>();
    directoriesToCheck.addAll(toDelete.map(m => m.parentPath));

    while (directoriesToCheck.length > 0) {
      final d = new Directory(directoriesToCheck.pop());
      if (d.isEmpty()) {
        await d.delete();
        directoriesToCheck.add(d.parent);
      }
    }
  }

  Future<MusicFolderDto> getAll(KeepState? state) async {
    var query = this.musics.asQuery();
    if (state != null) {
      query = query.where(m => m.state == state);
    }
    query = query.orderBy(m => m.path);

    final musics = await query.getAll();
    return _buildMusicHierarchy(musics, root);
  }

  /// Persist the music changes to the DB
  Future<void> save(Music music) async {
    await this.musics.update(toAdd);
  }

  /// Scans the given folder and populates the DB with the scanned musics
  Future<void> scanFolder(Directory root) async {
    debugPrint("[$tag]: Rescanning $root...");
    final scanned = <Music>[];
    await _scan(scanned, '', root);
    debugPrint("[$tag]: Scanned ${scanned.length} musics.");

    final existing = (await this.musics.getAll()).toDictionary(m => m.path);
    final toAdd = <Music>[];
    for (var m in scanned) {
      if (!existing.contains(m.path)) {
        toAdd.add(m);
      }
    }

    debugPrint("[$tag]: Adding ${toAdd.length} musics to DB (not yet tracked).");
    await this.musics.insertAll(toAdd);
  }

  MusicFolderDto _buildMusicHierarchy(List<Music> musics) {
    final root = new MusicFolderDto(path: '');
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
    return _lookupSplits(child, prefix, splits, depth + 1);
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
        artists: metadata.trackArtistNames ?? [],
        album: metadata.albumName,
        albumArtist: metadata.albumArtistName,
      );
    } catch (e) {
      debugPrint("[$tag]_fetchTag($path) caught error: $e");
      return null;
    }
  }
}
