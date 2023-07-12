import 'package:flutter_test/flutter_test.dart';
import 'package:music_filter/models/music_folder.dart';
import 'package:music_filter/models/music_folder_volatile.dart';

import '../_test_utils/mock_music.dart';

typedef FBuilder = MusicFolderBuilder<MusicFolder>;
typedef MFBuilder = MusicFolderBuilder<MutableMusicFolder>;

void Function() lookupReturnsFolderIffItExists(FBuilder builder) => () {
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
      expect(root.lookup("child_1/grandchild_C"), null);
      expect(root.lookup("child_1/grandchild_A"), secondGen[0]);
      expect(root.lookup("child_1/grandchild_B"), secondGen[1]);
      expect(root.lookup("child_1/grandchild_A/foo"), thirdGen[0]);
      expect(root.lookup("child_1/grandchild_B/foo"), null);
      expect(root.lookup("child_0/grandchild_A/foo"), null);
      expect(root.lookup("child_2/grandchild_A/foo"), null);
    };

Future<void> Function() lookupOrCreateReturnsFolderIfItExists(
        MFBuilder builder) =>
    () async {
      final firstGen = [
        builder.addSubfolder(builder.root, "child_0"),
        builder.addSubfolder(builder.root, "child_1"),
      ];
      final secondGen = [
        builder.addSubfolder(firstGen[1], "child_1/grandchild_A"),
        builder.addSubfolder(firstGen[1], "child_1/grandchild_B"),
      ];

      final root = builder.root;
      expect(await root.lookupOrCreate("child_0"), firstGen[0]);
      expect(await root.lookupOrCreate("child_1"), firstGen[1]);
      final child2 = await root.lookupOrCreate("child_2");
      expect(child2, isNotNull);
      expect(child2.parent, root);
      expect(child2.children, isEmpty);

      expect(await root.lookupOrCreate("child_1/grandchild_A"), secondGen[0]);
      expect(await root.lookupOrCreate("child_1/grandchild_B"), secondGen[1]);
      final grandC = await root.lookupOrCreate("child_1/grandchild_C");
      expect(grandC, isNotNull);
      expect(grandC.parent, firstGen[1]);
      expect(grandC.parent?.parent, root);
      expect(grandC.children, isEmpty);

      final grandCousin = await root.lookupOrCreate("long_lost/relative/baby");
      expect(grandCousin, isNotNull);
      expect(grandCousin.parent?.parent?.parent, root);
      expect(grandCousin.children, isEmpty);

      expect(
          root.children,
          containsAll(<MusicFolder>[
                child2,
                grandCousin.parent!.parent!,
              ] +
              firstGen));
      expect(
          firstGen[1].children, containsAll(<MusicFolder>[grandC] + secondGen));
    };

Future<void> Function() addMusicsAddsThemToCorrectFolder(MFBuilder builder) =>
    () async {
      final initial = mockMusics(["another.flac", "child_0/music1.mp3"]);
      final child0 = builder.addSubfolder(builder.root, "child_0");
      builder.addMusics(builder.root, [initial[0]]);
      builder.addMusics(child0, [initial[1]]);

      final added = mockMusics(["yet_another.flac", "child_0/bonus/live.mp3"]);
      final root = builder.root;
      await root.addMusics(added);

      expect(root.allDescendants, containsAll(initial + added));
      expect(root.musics, unorderedEquals([initial[0], added[0]]));
      expect(child0.allDescendants, unorderedEquals([initial[1], added[1]]));
      expect(child0.musics, unorderedEquals([initial[1]]));
      expect(child0.children.single.musics, unorderedEquals([added[1]]));
    };

Future<void> Function() removeMusicsRemoveThemFromCorrectFolder(
        MFBuilder builder) =>
    () async {
      final initial = mockMusics([
        "another.flac",
        "yet_another.flac",
        "child_0/music1.mp3",
        "child_0/bonus/live.mp3",
      ]);
      final child0 = builder.addSubfolder(builder.root, "child_0");
      final bonus = builder.addSubfolder(child0, "child_0/bonus");
      builder.addMusics(builder.root, initial.sublist(0, 2));
      builder.addMusics(child0, [initial[2]]);
      builder.addMusics(bonus, [initial[3]]);

      final root = builder.root;
      await root.removeMusics([initial[1], initial[2]]);

      expect(root.allDescendants, unorderedEquals([initial[0], initial[3]]));
      expect(root.musics, unorderedEquals([initial[0]]));
      expect(child0.musics, isEmpty);
      expect(bonus.musics, unorderedEquals([initial[3]]));

      await root.removeMusics([initial[3]]);
      expect(root.allDescendants, unorderedEquals([initial[0]]));
      expect(root.children, isEmpty);
    };

void main() {
  volatile() => VolatileMusicFolderBuilder();
  test('Volatile music folder lookup returns folder when it exists',
      lookupReturnsFolderIffItExists(volatile()));

  test(
      'Volatile music folder lookupOrCreate returns folder when it exists, and creates new one if not',
      lookupOrCreateReturnsFolderIfItExists(volatile()));

  test(
      'Volatile music folder addMusics adds them to correct folder, and creates folder if needed',
      addMusicsAddsThemToCorrectFolder(volatile()));

  test(
      'Volatile music folder removeMusics removes them from correct folder, and deletes folder if empty',
      removeMusicsRemoveThemFromCorrectFolder(volatile()));
}
