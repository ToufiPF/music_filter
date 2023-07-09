import 'package:flutter_test/flutter_test.dart';
import 'package:music_filter/models/music.dart';
import 'package:music_filter/models/music_folder.dart';
import 'package:music_filter/models/music_folder_volatile.dart';

typedef FolderFactory = MusicFolder Function(String path, MusicFolder? parent,
    List<MusicFolder> children, List<Music> musics);

typedef MutableFactory = MutableMusicFolder Function(
    String path, MusicFolder? parent);

void Function() testMusicFolderLookupReturnsFolderWhenItExists(
        MusicFolderBuilder builder) =>
    () {
      final firstGen = [
        builder.addSubfolder(builder.root, "child_0"),
        builder.addSubfolder(builder.root, "child_1"),
      ];
      final secondGen = [
        builder.addSubfolder(firstGen[1], "child_1/grandchild_A"),
        builder.addSubfolder(firstGen[1], "child_1/grandchild_B"),
      ];
      final thirdGen = [
        builder.addSubfolder(secondGen[0], "child_1/grandchild_A/foo"),
      ];

      final root = builder.root;
      expect(root.lookup("child_0"), firstGen[0]);
      expect(root.lookup("child_1"), firstGen[1]);
      expect(root.lookup("child_1/grandchild_A"), secondGen[0]);
      expect(root.lookup("child_1/grandchild_B"), secondGen[1]);
      expect(root.lookup("child_1/grandchild_A/foo"), thirdGen[0]);
      expect(root.lookup("child_1/grandchild_B/foo"), null);
    };

void main() {
  test(
      'music folder lookup returns folder when it exists',
      testMusicFolderLookupReturnsFolderWhenItExists(
          VolatileMusicFolderBuilder()));
}
