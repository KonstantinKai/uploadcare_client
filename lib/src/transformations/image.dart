import 'dart:ui';

import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/common.dart';

enum ImageFormatTValue {
  /// convert an image to JPEG.
  Jpeg,

  /// convert an image to PNG.
  Png,

  /// convert an image to WebP.
  Webp,

  /// try converting to WebP and fall back to JPEG when a user browser provides no WebP support.
  Auto,
}

/// Convert an image to one of the supported output formats: [ImageFormatTValue]
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

/// Convert JPEG to Progressive JPEG. Has no effect on non-JPEGs. Does not force image formats to jpeg.
/// if [value] is equal `true` then are using multi-scan rendering.
class ProgressiveTransformation extends BooleanTransformation
    implements ImageTransformation {
  ProgressiveTransformation([bool value = false]) : super(value);

  @override
  String get operation => 'progressive';
}

/// Instruct Uploadcare CDN whether it should rotate an image according to the EXIF orientation tag or not.
class AutoRotateTransformation extends BooleanTransformation
    implements ImageTransformation {
  AutoRotateTransformation([bool value = true]) : super(value);

  @override
  String get operation => 'autorotate';
}

/// Rotate an image counterclockwise.
/// [value] should be in `-360..360` range
class RotateTransformation extends IntTransformation
    implements ImageTransformation {
  RotateTransformation(int value)
      : assert(value >= -360 && value <= 360, 'Should be in -360..360 range'),
        super(value);

  @override
  String get operation => 'rotate';
}

/// Flip an image (mirror-reverse an image across the horizontal axis).
class FlipTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'flip';
}

/// Mirror an image (mirror-reverse an image across the vertical axis).
class MirrorTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'mirror';
}

/// Desaturate an image.
class GrayscaleTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'grayscale';
}

/// Invert the colors of an image.
class InvertTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'invert';
}

/// Auto-enhance an image by performing the following operations: auto levels, auto contrast, and saturation sharpening.
/// [value] should be in `0..100` range
class EnhanceTransformation extends IntTransformation
    implements ImageTransformation {
  EnhanceTransformation([int value = 50])
      : assert(value >= 0 && value <= 100, 'Should be in 0..100 range'),
        super(value);

  @override
  String get operation => 'enhance';
}

/// Sharpen an image, might be especially useful with images that were subjected to downscaling.
/// [value] should be in `0..20` range
class SharpTransformation extends IntTransformation
    implements ImageTransformation {
  SharpTransformation([int value = 5])
      : assert(value >= 0 && value <= 20, 'Should be in 0..20 range'),
        super(value);

  @override
  String get operation => 'sharp';
}

/// Blur images by the strength factor. The filtering mode is Gaussian Blur, where strength parameter sets the blur radius — effect intensity.
/// Technically, strength controls the Gaussian Blur standard deviation multiplied by ten.
/// Note, different strength values do not affect the operation performance.
/// [value] should be in `0..5000` range
class BlurTransformation extends IntTransformation
    implements ImageTransformation {
  BlurTransformation([int value = 5])
      : assert(value >= 0 && value <= 5000, 'Should be in 0..5000 range'),
        super(value);

  @override
  String get operation => 'blur';
}

/// Strip off an ICC profile from an image based on the profile [value] in *kilobytes*.
/// [value] should be positive [int]
class MaxIccSizeTransformation extends IntTransformation
    implements ImageTransformation {
  MaxIccSizeTransformation([int value = 10])
      : assert(value >= 0, 'Should be positive int'),
        super(value);

  @override
  String get operation => 'max_icc_size';
}

enum StretchTValue {
  /// stretch the source image.
  On,

  /// forbid stretching the source image.
  Off,

  /// forbid stretching the source image, render color-filled frame around.
  Fill,
}

/// Set the [ImageResizeTransformation] behavior when provided [Size] are greater than the source image dimensions.
/// The directive should come before [ImageResizeTransformation] transformation to give any effect.
class StretchTransformation extends EnumTransformation<StretchTValue>
    implements ImageTransformation {
  StretchTransformation([StretchTValue value = StretchTValue.On])
      : assert(value != null),
        super(value);

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

/// Set the fill color when converting alpha channel enabled images to JPEG, with [CropTransformation] or [StretchTransformation].
class SetFillTransformation extends Transformation
    implements ImageTransformation {
  /// fill color
  final Color color;

  SetFillTransformation([this.color = const Color(0xFFFFFFFF)])
      : assert(color != null, 'Should be non-null color value');

  @override
  String get operation => 'setfill';

  @override
  List<String> get params =>
      [color.value.toRadixString(16).replaceRange(0, 2, '')];
}

/// Downscale an image along one of the axes (the one with smaller linear size) and crop the rest.
class ScaleCropTransformation extends ResizeTransformation
    implements ImageTransformation {
  /// centering the crop focus.
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

/// Resize an image to fit into specified dimensions, proportional.
class PreviewTransformation extends ResizeTransformation
    implements ImageTransformation {
  PreviewTransformation([Size size = const Size.square(2048)]) : super(size);

  @override
  String get operation => 'preview';
}

/// Crop an image to fit into specified dimensions, implement optional offsets.
class CropTransformation extends ResizeTransformation
    implements ImageTransformation {
  /// optional offsets along one or both of the axes
  final Offset offset;

  /// centering the crop focus.
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

/// Resize an image to fit into specified dimensions.
class ImageResizeTransformation extends ResizeTransformation
    implements ImageTransformation {
  ImageResizeTransformation(Size size) : super(size);
}
