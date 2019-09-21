import 'dart:ui';

import 'package:uploadcare_client/src/transformations/base.dart';

enum QualityTValue {
  Lightest,
  Lighter,
  Normal,
  Better,
  Best,
}

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
