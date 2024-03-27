import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/player.dart';
import '../../util/misc.dart';

class SeekBarWrapper extends StatelessWidget {
  const SeekBarWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerStateController>(context, listen: false);

    // currentMusicDurationStream yields nullable Durations
    return StreamBuilder<Duration?>(
        stream: player.currentMusicDurationStream,
        builder: (_, duration) => StreamBuilder<Duration>(
            stream: player.playerBufferedPositionStream,
            builder: (_, buffered) => StreamBuilder<Duration>(
                stream: player.playerPositionStream,
                builder: (_, position) => SeekBar(
                      duration: duration.data ?? Duration.zero,
                      bufferedPosition: buffered.data ?? Duration.zero,
                      position: position.data ?? Duration.zero,
                      // onChanged: (position) {
                      //   if (position < buffered.data!) {
                      //     player.seekTo(position);
                      //   }
                      // },
                      onChangeEnd: player.seekTo,
                    ))));
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  Duration get remaining => duration - position;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  static String formatSeconds(int seconds) {
    const minute = 60;
    const hour = 60 * minute;

    if (seconds >= hour) {
      int hours = seconds ~/ hour;
      int min = (seconds % hour) ~/ minute;
      int sec = seconds % minute;
      return "$hours:${min.toZeroPaddedString(2)}:${sec.toZeroPaddedString(2)}";
    } else {
      int min = seconds ~/ minute;
      int sec = seconds % minute;
      return "${min.toZeroPaddedString(2)}:${sec.toZeroPaddedString(2)}";
    }
  }

  double? _dragPosition;
  bool _dragging = false;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final durationMs = widget.duration.inMilliseconds.toDouble();
    final bufferedMs = widget.bufferedPosition.inMilliseconds.toDouble();
    final positionMs = min(
        _dragPosition ?? widget.position.inMilliseconds.toDouble(), durationMs);

    final duration = formatSeconds(widget.duration.inSeconds);
    final position = formatSeconds(positionMs ~/ 1000);
    final remaining = formatSeconds((durationMs - positionMs) ~/ 1000);

    if (!_dragging) {
      _dragPosition = null;
    }

    return Stack(
      children: [
        // first slider shows the state of the buffered position
        // (until where we can drag without lag)
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.blue.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: durationMs,
              value: min(bufferedMs, durationMs),
              onChanged: (value) {},
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: positionMs,
            onChanged: (value) {
              _dragging = true;
              widget.onChanged?.call(Duration(milliseconds: value.round()));
              setState(() => _dragPosition = value);
            },
            onChangeEnd: (value) {
              widget.onChangeEnd?.call(Duration(milliseconds: value.round()));
              _dragging = false;
            },
          ),
        ),
        Positioned(
          left: 16.0,
          bottom: 0.0,
          child: Text("$position/$duration", style: theme.textTheme.bodySmall),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text("-$remaining", style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

/// A thumb component that is never visible
class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
