import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class Constants {
  static const delayBeforeTextScroll = Duration(milliseconds: 1000);
  static const delayBetweenTextScrolls = Duration(milliseconds: 1000);

  static Widget scrollingText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection textDirection = TextDirection.ltr,
  }) =>
      TextScroll(
        text,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        delayBefore: delayBeforeTextScroll,
        pauseBetween: delayBetweenTextScrolls,
        intervalSpaces: 8,
      );
}
