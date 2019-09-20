import 'dart:ui';

import 'package:uploadcare_client/src/transformations/common.dart';

enum VideoFormatTValue {
  Webm,
  Ogg,
  Mp4,
}

class VideoFormatTransformation extends EnumTransformation<VideoFormatTValue>
    implements VideoTransformation {
  VideoFormatTransformation([VideoFormatTValue value = VideoFormatTValue.Mp4])
      : super(value);

  @override
  String get valueAsString {
    switch (value) {
      case VideoFormatTValue.Webm:
        return 'webm';
      case VideoFormatTValue.Ogg:
        return 'ogg';
      default:
        return 'mp4';
    }
  }

  @override
  String get operation => 'format';
}

enum VideoResizeTValue {
  PreserveRatio,
  BreakRation,
  ScaleCrop,
  AddPadding,
}

class VideoResizeTransformation extends ResizeTransformation
    implements EnumTransformation<VideoResizeTValue>, VideoTransformation {
  final VideoResizeTValue value;

  VideoResizeTransformation(Size size, [this.value])
      : assert(size.width != null ? size.width % 4 == 0 : true,
            'Should be a non-zero integer divisible by 4'),
        assert(size.height != null ? size.height % 4 == 0 : true,
            'Should be a non-zero integer divisible by 4'),
        super(size);

  @override
  String get valueAsString {
    switch (value) {
      case VideoResizeTValue.PreserveRatio:
        return 'preserve_ratio';
      case VideoResizeTValue.BreakRation:
        return 'break_ratio';
      case VideoResizeTValue.ScaleCrop:
        return 'scale_crop';
      case VideoResizeTValue.AddPadding:
        return 'add_padding';
      default:
        return '';
    }
  }

  @override
  List<String> get params => [
        ...super.params,
        if (value != null) valueAsString,
      ];
}

class CutTransformation extends Transformation implements VideoTransformation {
  final Duration start;
  final Duration length;
  final bool end;

  CutTransformation(
    this.start, {
    this.length,
    this.end = false,
  });

  String _digitsWithLeadingZero(int n, [bool isHour = false]) {
    if (isHour) {
      return n < 10 ? '00$n' : n < 100 ? '0$n' : '$n';
    }

    return n >= 10 ? '$n' : '0$n';
  }

  String _formatDuration(Duration duration) {
    final String hours =
        _digitsWithLeadingZero(duration.inHours.remainder(60), true);
    final String minutes =
        _digitsWithLeadingZero(duration.inMinutes.remainder(60));
    final String seconds =
        _digitsWithLeadingZero(duration.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }

  @override
  String get operation => 'cut';

  @override
  List<String> get params => [
        _formatDuration(start),
        if (length != null || end)
          length != null ? _formatDuration(length) : 'end',
      ];
}
