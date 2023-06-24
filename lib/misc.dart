extension IntExtensions on int {
  /// [toString] but with the returned string padded with as many zeros
  /// as required to meet the minimum length
  String toZeroPaddedString(int minDigits) {
    String val = toString();
    return val.padLeft(minDigits, '0');
  }
}
