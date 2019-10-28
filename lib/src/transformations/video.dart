import 'dart:ui';

import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/common.dart';

enum VideoFormatTValue {
  /// WebM is an open media file format designed for the web.
  /// Video streams are compressed via VP8 or VP9 video codec.
  /// Audio gets compressed with Vorbis or Opus, more.
  /// WebM is compatible with many of the current devices and browsers and backed by Google.
  Webm,

  /// Ogg/Theora is a free and open video compression format from Xiph.org.
  /// Theora is considered competitive at low bitrates, which makes it suitable for the web, more.
  /// Theora is backed by the community is supported by fewer browsers than webm.
  Ogg,

  /// MPEG-4 with its H.264 or H.265 video codec is widely supported across devices and browsers.
  /// Videos encoded with mp4 will work on Android and iOS, in Safari, Chrome, and IE.
  /// Choose it when you want to go universal or in case you need a fallback.
  Mp4,
}

/// Converts a file to one of the HTML5 video formats: [VideoFormatTValue]
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
  /// Preserve the aspect ratio of the original file.
  PreserveRatio,

  /// Match the output video to provided dimensions, no matter the original aspect ratio.
  BreakRatio,

  /// Match the output video to provided dimensions, crop the rest of the pixels along one of the axes (top/bottom or left/right).
  ScaleCrop,

  /// Letterbox the video to match the output frame size exactly (add black bars).
  AddPadding,
}

/// Resizes a video to the specified dimensions. The operation follows the behavior specified by one of the four presets: [VideoResizeTValue]
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
      case VideoResizeTValue.BreakRatio:
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

/// Cuts out a video fragment based on the following parameters: [start], [length]
///
/// Example:
/// ```dart
/// CutTransformation(
///   const const Duration(seconds: 109),
///   length: const Duration(
///     seconds: 30,
///   ),
/// )
/// // or
/// CutTransformation(
///   const const Duration(seconds: 109),
///   end: true,
/// )
/// ```
class CutTransformation extends Transformation implements VideoTransformation {
  /// Defines the starting point of a fragment to cut based on your input file timeline.
  final Duration start;

  /// Defines the duration of that fragment.
  final Duration length;

  /// Includes all the duration of your input starting at [start].
  final bool end;

  CutTransformation(
    this.start, {
    this.length,
    this.end = true,
  }) : assert(length != null || end != null);

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
        if (length != null) _formatDuration(length),
        if (length == null && end) 'end',
      ];
}

/// Creates N thumbnails for your video, where N is a non-zero integer ranging from 1 to 50; defaults to 1.
///
/// If the operation is omitted, a single thumbnail gets generated from the very middle of your video.
/// If you define another N, thumbnails are generated from the frames evenly distributed along your video timeline.
/// I.e., if you have a 20-second video with N set to 20, you will get a thumbnail per every second of your video.
class VideoThumbsGenerateTransformation extends NullParamTransformation
    implements VideoTransformation {
  final int amount;

  VideoThumbsGenerateTransformation([this.amount = 1])
      : assert(amount > 0 && amount <= 50, 'Should be in 1..50 range');

  @override
  String get operation => 'thumbs~$amount';
}
