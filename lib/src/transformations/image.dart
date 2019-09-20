import 'dart:ui';

import 'package:uploadcare_client/src/transformations/common.dart';

enum ImageFormatTValue {
  Jpeg,
  Png,
  Webp,
  Auto,
}

class ImageFormatTransformation extends EnumTransformation<ImageFormatTValue>
    implements ImageTransformation {
  ImageFormatTransformation(ImageFormatTValue value) : super(value);

  @override
  String get valueAsString {
    switch (value) {
      case ImageFormatTValue.Auto:
        return 'auto';
      case ImageFormatTValue.Jpeg:
        return 'jpeg';
      case ImageFormatTValue.Png:
        return 'png';
      case ImageFormatTValue.Webp:
        return 'webp';
      default:
        return '';
    }
  }

  @override
  String get operation => 'format';
}

class ProgressiveTransformation extends BooleanTransformation
    implements ImageTransformation {
  ProgressiveTransformation([bool value = false]) : super(value);

  @override
  String get operation => 'progressive';
}

class AutoRotateTransformation extends BooleanTransformation
    implements ImageTransformation {
  AutoRotateTransformation([bool value = true]) : super(value);

  @override
  String get operation => 'autorotate';
}

class RotateTransformation extends IntTransformation
    implements ImageTransformation {
  RotateTransformation(int value) : super(value);

  @override
  String get operation => 'rotate';
}

class FlipTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'flip';
}

class MirrorTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'mirror';
}

class GrayscaleTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'grayscale';
}

class InvertTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'invert';
}

class EnhanceTransformation extends IntTransformation
    implements ImageTransformation {
  EnhanceTransformation([int value = 50])
      : assert(value >= 0 && value <= 100, 'Should be in 0..100 range'),
        super(value);

  @override
  String get operation => 'enhance';
}

class SharpTransformation extends IntTransformation
    implements ImageTransformation {
  SharpTransformation([int value = 5])
      : assert(value >= 0 && value <= 20, 'Should be in 0..20 range'),
        super(value);

  @override
  String get operation => 'sharp';
}

class BlurTransformation extends IntTransformation
    implements ImageTransformation {
  BlurTransformation([int value = 5])
      : assert(value >= 0 && value <= 5000, 'Should be in 0..5000 range'),
        super(value);

  @override
  String get operation => 'blur';
}

class MaxIccSizeTransformation extends IntTransformation
    implements ImageTransformation {
  MaxIccSizeTransformation([int value = 10])
      : assert(value > 0, 'Should be positive int'),
        super(value);

  @override
  String get operation => 'max_icc_size';
}

enum StretchTValue {
  On,
  Off,
  Fill,
}

class StretchTransformation extends EnumTransformation<StretchTValue>
    implements ImageTransformation {
  StretchTransformation([StretchTValue value = StretchTValue.On])
      : super(value);

  @override
  String get valueAsString {
    switch (value) {
      case StretchTValue.Fill:
        return 'fill';
      case StretchTValue.Off:
        return 'off';
      default:
        return 'on';
    }
  }

  @override
  String get operation => 'stretch';
}

class SetFillTransformation extends Transformation
    implements ImageTransformation {
  final Color color;

  SetFillTransformation([this.color = const Color(0xFFFFFFFF)]);

  @override
  String get operation => 'setfill';

  @override
  List<String> get params =>
      [color.value.toRadixString(16).replaceRange(0, 2, '')];
}

class ScaleCropTransformation extends ResizeTransformation
    implements ImageTransformation {
  final bool center;

  ScaleCropTransformation(Size size, [this.center = false]) : super(size);

  @override
  String get operation => 'scale_crop';

  @override
  List<String> get params => [
        ...super.params,
        if (center) 'center',
      ];
}

class PreviewTransformation extends ResizeTransformation
    implements ImageTransformation {
  PreviewTransformation([Size size = const Size.square(2048)]) : super(size);

  @override
  String get operation => 'preview';
}

class CropTransformation extends ResizeTransformation
    implements ImageTransformation {
  final Offset offset;
  final bool center;

  CropTransformation(
    Size size, [
    this.offset = const Offset(0, 0),
    this.center = false,
  ]) : super(size);

  @override
  String get operation => 'crop';

  @override
  List<String> get params => [
        ...super.params,
        center ? 'center' : '${offset.dx?.toInt()},${offset.dy?.toInt()}',
      ];
}

class ImageResizeTransformation extends ResizeTransformation
    implements ImageTransformation {
  ImageResizeTransformation(Size size) : super(size);
}
