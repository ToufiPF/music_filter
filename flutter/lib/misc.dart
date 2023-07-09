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
