import 'package:flutter_test/flutter_test.dart';
import 'package:music_filter/util/misc.dart';

void main() {
  test('Collapse indices empty', () {
    expect(<int>[].collapseToRanges(), orderedEquals([]));
  });

  test('Collapse indices normal uses', () {
    expect([0, 1, 2, 3, 4].collapseToRanges(), orderedEquals([(0, 5)]));
    expect([0, 1, 2, 4].collapseToRanges(), orderedEquals([(0, 3), (4, 1)]));
    expect([0, 2].collapseToRanges(), orderedEquals([(0, 1), (2, 1)]));
    expect([10].collapseToRanges(), orderedEquals([(10, 1)]));
  });
}
