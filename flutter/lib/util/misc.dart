import 'package:collection/collection.dart';

extension IntExtensions on int {
  /// [toString] but with the returned string padded with as many zeros
  /// as required to meet the minimum length
  String toZeroPaddedString(int minDigits) {
    String val = toString();
    return val.padLeft(minDigits, '0');
  }
}

extension StringExtensions on String {
  /// If the string has the given prefix,
  /// returns a new one without it, otherwise do nothing
  String removePrefix(String prefix) =>
      startsWith(prefix) ? substring(prefix.length) : this;

  /// Returns the same string with " and \\ (quotes and anti-slashes) escaped
  String escapeDoubleQuotes() =>
      replaceAll('"', '\\"').replaceAll('\\', '\\\\');
}

extension IndicesListExtensions on Iterable<int> {
  /// Given a list of indices,
  /// returns a list with (start, length) for each segment of successive indices.
  ///
  /// Ex: `[2, 3, 4, 6].collapseToRanges() => [(2, 3), (6, 1)]`
  List<(int, int)> collapseToRanges() {
    assert(toSet().length == length,
        "There should be no duplicates in this list of indices");

    final res = <(int, int)>[];
    if (isEmpty) return res;

    final list = toList(growable: true)..sort();
    int start = list.first;
    int prev = start;
    int consecutive = 1;
    for (int i in list.slice(1)) {
      if (prev + 1 == i) {
        prev = i;
        consecutive += 1;
      } else {
        res.add((start, consecutive));
        start = prev = i;
        consecutive = 1;
      }
    }

    res.add((start, consecutive));
    return res;
  }
}
