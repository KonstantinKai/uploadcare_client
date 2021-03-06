import '../measures.dart';
import 'base.dart';
import 'common.dart';

enum ImageFormatTValue {
  /// Convert an image to JPEG.
  Jpeg,

  /// Convert an image to PNG.
  Png,

  /// Convert an image to WebP.
  Webp,

  /// Try converting to WebP and fall back to JPEG when a user browser provides no WebP support.
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

/// Set the fill color when converting alpha channel enabled images to JPEG, with [CropTransformation] or [StretchTransformation].
class SetFillTransformation extends Transformation
    implements ImageTransformation {
  /// fill color
  final String hexColor;

  SetFillTransformation([this.hexColor = '#ffffff']);

  @override
  String get operation => 'setfill';

  @override
  List<String> get params => [hexColor.replaceRange(0, 1, '')];
}

/// Type value which enables smart image analysis for [ScaleCropTransformation]
enum ScaleCropTypeTValue {
  /// default image analysis mode, face detection, object detection and corner points detection
  Smart,

  /// same as [ScaleCropTypeTValue.Smart], face detection, object detection and corner points detection
  SmartFacesObjectsPoints,

  /// face detection, followed by object detection
  SmartFacesObjects,

  /// face detection, followed by corner points detection
  SmartFacesPoints,

  /// object detection, followed by face detection, followed by corner points detection
  SmartObjectsFacesPoints,

  /// object detection, followed by face detection
  SmartObjectsFaces,

  /// object detection, followed by corner points detection
  SmartObjectsPoints,

  /// corner points detection or manual region specified by offset parameter
  SmartPoints,

  /// object detection or manual region specified by offset parameter
  SmartObjects,

  /// face detection or manual region specified by offset parameter
  SmartFaces,
}

/// Downscale an image along one of the axes (the one with smaller linear size) and crop the rest.
/// The method can be implemented with manual, center-focused or “smart crop” behavior.
class ScaleCropTransformation extends ResizeTransformation
    implements EnumTransformation<ScaleCropTypeTValue>, ImageTransformation {
  /// an optional [ScaleCropTypeTValue] which enables smart image analysis.
  /// Each smart analysis mode combines various methods for detecting areas of interest in an image.
  /// The methods you include are applied sequentially.
  /// The algorithm switches to the next method only if no regions were found by the previous one.
  /// If no regions of interest were found, the [offset] setting is used to crop an image.
  @override
  final ScaleCropTypeTValue? value;

  /// setting is used to crop an image. When no [offset] are specified, images get center-cropped
  final Offsets? offset;

  /// centering the crop focus.
  final bool center;

  ScaleCropTransformation(
    Dimensions size, {
    ScaleCropTypeTValue? type,
    this.offset,
    this.center = false,
  })  : value = type,
        super(size);

  @override
  String get operation => 'scale_crop';

  @override
  List<String> get params => [
        ...super.params,
        if (value != null) valueAsString,
        if (offset != null)
          '${offset!.dx},${offset!.dy}'
        else if (center)
          'center',
      ];

  @override
  String get valueAsString {
    switch (value) {
      case ScaleCropTypeTValue.Smart:
        return 'smart';
      case ScaleCropTypeTValue.SmartFacesObjectsPoints:
        return 'smart_faces_objects_points';
      case ScaleCropTypeTValue.SmartFacesObjects:
        return 'smart_faces_objects';
      case ScaleCropTypeTValue.SmartFacesPoints:
        return 'smart_faces_points';
      case ScaleCropTypeTValue.SmartObjectsFacesPoints:
        return 'smart_objects_faces_points';
      case ScaleCropTypeTValue.SmartObjectsFaces:
        return 'smart_objects_faces';
      case ScaleCropTypeTValue.SmartObjectsPoints:
        return 'smart_objects_points';
      case ScaleCropTypeTValue.SmartPoints:
        return 'smart_points';
      case ScaleCropTypeTValue.SmartObjects:
        return 'smart_objects';
      case ScaleCropTypeTValue.SmartFaces:
        return 'smart_faces';
      default:
        return '';
    }
  }
}

/// Resize an image to fit into specified dimensions, proportional.
class PreviewTransformation extends ResizeTransformation
    implements ImageTransformation {
  PreviewTransformation([Dimensions size = const Dimensions.square(2048)])
      : super(size);

  @override
  String get operation => 'preview';
}

/// Crop an image to fit into specified dimensions, implement optional offsets.
class CropTransformation extends ResizeTransformation
    implements ImageTransformation {
  /// optional offsets along one or both of the axes
  final Offsets offset;

  /// centering the crop focus.
  final bool center;

  CropTransformation(
    Dimensions size, [
    this.offset = Offsets.zero,
    this.center = false,
  ]) : super(size);

  @override
  String get operation => 'crop';

  @override
  List<String> get params => [
        ...super.params,
        center ? 'center' : '${offset.dx},${offset.dy}',
      ];
}

/// Resize an image to fit into specified dimensions.
class ImageResizeTransformation extends ResizeTransformation
    implements ImageTransformation {
  ImageResizeTransformation(Dimensions size) : super(size);
}

class OverlayCoordinates {
  final Offsets offset;
  final String? predefined;

  const OverlayCoordinates._({
    this.offset = Offsets.zero,
    this.predefined,
  });

  const OverlayCoordinates(this.offset) : predefined = null;

  static const top = OverlayCoordinates._(predefined: 'top');
  static const bottom = OverlayCoordinates._(predefined: 'bottom');
  static const left = OverlayCoordinates._(predefined: 'left');
  static const right = OverlayCoordinates._(predefined: 'right');
  static const center = OverlayCoordinates._(predefined: 'center');

  @override
  String toString() => predefined ?? '${offset.dx}p,${offset.dy}p';
}

/// The overlay operation allows to layer images one over another.
///
/// Example:
/// ```dart
/// CdnImage('image-id-1')
/// ..transform(OverlayTransformation(
///   'image-id-2',
///   dimensions: Size(40, 30),
///   coordinates: OverlayCoordinates.center,
///   opacity: 40,
/// ))
/// ..transform(OverlayTransformation(
///   'image-id-3',
///   dimensions: Size(40, 30),
///   coordinates: OverlayCoordinates(const Offset(40, 90)),
/// ));
/// ```
class OverlayTransformation extends Transformation
    implements ImageTransformation {
  /// UUID of an image to be layered over input. To be recognized by :uuid, that image should be related to any project of your account.
  final String imageId;

  /// Linear relative dimensions of the overlay image. The aspect ratio of an overlay is preserved.
  final Dimensions? dimensions;

  /// Relative position of the overlay over your input. By default, an overlay is positioned in the top-left corner of an input.
  /// Coordinates represent an offset along each of the axes in either pixel or percent format.
  /// In general, the coordinate system is similar to the CSS background-position. See [OverlayCoordinates].
  final OverlayCoordinates? coordinates;

  /// Controls the opacity of the overlay in percent format.
  final int? opacity;

  OverlayTransformation(
    this.imageId, {
    this.dimensions,
    this.coordinates,
    this.opacity,
  })  : assert(dimensions != null
            ? dimensions.width > -1 && dimensions.height > -1
            : true),
        assert(coordinates != null ? dimensions != null : true,
            'dimensions should be provided if you are using `coordinates`'),
        assert(
            opacity != null
                ? dimensions != null &&
                    coordinates != null &&
                    opacity >= 0 &&
                    opacity <= 100
                : true,
            '`opacity` should be in 0..100 range');

  @override
  String get operation => 'overlay';

  @override
  List<String> get params => [
        imageId,
        if (dimensions != null) '${dimensions!.width}px${dimensions!.height}p',
        if (coordinates != null) coordinates.toString(),
        if (opacity != null) '${opacity}p',
      ];

  @override
  bool operator ==(dynamic other) =>
      other is OverlayTransformation &&
      runtimeType == other.runtimeType &&
      imageId == other.imageId &&
      dimensions == other.dimensions &&
      coordinates == other.coordinates &&
      opacity == other.opacity;

  @override
  int get hashCode =>
      imageId.hashCode ^
      dimensions.hashCode ^
      coordinates.hashCode ^
      opacity.hashCode;
}
