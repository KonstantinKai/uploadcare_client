import 'dart:ui';

import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';
import 'package:uploadcare_client/src/transformations/video.dart';

enum QualityTValue {
  /// lowest visual quality yet minimal loading times; smaller than [QualityTValue.Lighter].
  Lightest,

  /// saves traffic without a significant subjective quality loss; smaller file size compared to [QualityTValue.Normal].
  Lighter,

  /// suits most cases.
  Normal,

  /// better video quality, larger file size compared to [QualityTValue.Normal].
  Better,

  /// useful when you want to get perfect quality without paying much attention to file sizes; larger than [QualityTValue.Better] maximum size.
  Best,
}

/// Sets the level of source quality that affects file sizes and hence loading times and volumes of generated traffic.
class QualityTransformation extends EnumTransformation<QualityTValue>
    implements ImageTransformation, VideoTransformation {
  QualityTransformation([QualityTValue value = QualityTValue.Normal])
      : super(value);

  String get valueAsString {
    switch (value) {
      case QualityTValue.Lightest:
        return 'lightest';
      case QualityTValue.Lighter:
        return 'lighter';
      case QualityTValue.Better:
        return 'better';
      case QualityTValue.Best:
        return 'best';
      default:
        return 'normal';
    }
  }

  @override
  String get operation => 'quality';
}

/// Base class for resize-related transformations
class ResizeTransformation extends Transformation {
  final Size size;

  ResizeTransformation(this.size);

  String get _width => size.width != null ? size.width.toInt().toString() : '';
  String get _height =>
      size.height != null ? size.height.toInt().toString() : '';

  @override
  String get operation => 'resize';

  @override
  List<String> get params => ['${_width}x$_height'];
}

class GifToVideoTransformation extends Transformation {
  final List<VideoTransformation> transformations;

  GifToVideoTransformation([this.transformations = const []])
      : assert(
            (transformations.isNotEmpty &&
                    transformations.any((transformation) =>
                        transformation is! VideoFormatTransformation ||
                        transformation is! QualityTransformation)) ||
                true,
            'You can apply only format or quality transformations');

  @override
  String get operation => 'gif2video';

  @override
  List<String> get params => [
        for (Transformation transform in transformations)
          '${transform.delimiter}$transform',
      ];

  @override
  String get delimiter => '';
}
