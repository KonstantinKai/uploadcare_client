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
///
/// See https://uploadcare.com/docs/transformations/image/compression/#operation-format
class ImageFormatTransformation extends EnumTransformation<ImageFormatTValue>
    implements ImageTransformation {
  const ImageFormatTransformation(ImageFormatTValue value) : super(value);

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
///
/// See https://uploadcare.com/docs/transformations/image/compression/#operation-progressive
class ProgressiveTransformation extends BooleanTransformation
    implements ImageTransformation {
  const ProgressiveTransformation([bool value = false]) : super(value);

  @override
  String get operation => 'progressive';
}

/// Instruct Uploadcare CDN whether it should rotate an image according to the EXIF orientation tag or not.
///
/// See https://uploadcare.com/docs/transformations/image/rotate-flip/#operation-autorotate
class AutoRotateTransformation extends BooleanTransformation
    implements ImageTransformation {
  const AutoRotateTransformation([bool value = true]) : super(value);

  @override
  String get operation => 'autorotate';
}

/// Rotate an image counterclockwise.
/// [value] should be in `-360..360` range
///
/// See https://uploadcare.com/docs/transformations/image/rotate-flip/#operation-rotate
class RotateTransformation extends IntTransformation
    implements ImageTransformation {
  const RotateTransformation(int value)
      : assert(value >= -360 && value <= 360, 'Should be in -360..360 range'),
        super(value);

  @override
  String get operation => 'rotate';
}

/// Flip an image (mirror-reverse an image across the horizontal axis).
///
/// See https://uploadcare.com/docs/transformations/image/rotate-flip/#operation-flip
class FlipTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'flip';
}

/// Mirror an image (mirror-reverse an image across the vertical axis).
///
/// See https://uploadcare.com/docs/transformations/image/rotate-flip/#operation-mirror
class MirrorTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'mirror';
}

/// Desaturate an image.
///
/// See https://uploadcare.com/docs/transformations/image/colors/#operation-grayscale
class GrayscaleTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'grayscale';
}

/// Invert the colors of an image.
///
/// See https://uploadcare.com/docs/transformations/image/colors/#operation-invert
class InvertTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'invert';
}

/// Auto-enhance an image by performing the following operations: auto levels, auto contrast, and saturation sharpening.
/// [value] should be in `0..100` range
///
/// See https://uploadcare.com/docs/transformations/image/colors/#operation-enhance
class EnhanceTransformation extends IntTransformation
    implements ImageTransformation {
  const EnhanceTransformation([int value = 50])
      : assert(value >= 0 && value <= 100, 'Should be in 0..100 range'),
        super(value);

  @override
  String get operation => 'enhance';
}

/// Sharpen an image, might be especially useful with images that were subjected to downscaling.
/// [value] should be in `0..20` range
///
/// See https://uploadcare.com/docs/transformations/image/blur-sharpen/#operation-sharp
class SharpTransformation extends IntTransformation
    implements ImageTransformation {
  const SharpTransformation([int value = 5])
      : assert(value >= 0 && value <= 20, 'Should be in 0..20 range'),
        super(value);

  @override
  String get operation => 'sharp';
}

/// Blur images by the strength factor. The filtering mode is Gaussian Blur, where strength parameter sets the blur radius — effect intensity.
/// Technically, strength controls the Gaussian Blur standard deviation multiplied by ten.
/// Note, different strength values do not affect the operation performance.
/// [value] should be in `0..5000` range
///
/// See https://uploadcare.com/docs/transformations/image/blur-sharpen/#operation-blur
class BlurTransformation extends IntTransformation
    implements ImageTransformation {
  const BlurTransformation([int? value = 10])
      : assert(value != null ? value >= 0 && value <= 5000 : true,
            'Should be in 0..5000 range'),
        super(value);

  @override
  String get operation => 'blur';
}

/// Strip off an ICC profile from an image based on the profile [value] in *kilobytes*.
/// [value] should be positive [int]
///
/// See https://uploadcare.com/docs/transformations/image/colors/#operation-max-icc-size
class MaxIccSizeTransformation extends IntTransformation
    implements ImageTransformation {
  const MaxIccSizeTransformation([int value = 10])
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
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-stretch
class StretchTransformation extends EnumTransformation<StretchTValue>
    implements ImageTransformation {
  const StretchTransformation([StretchTValue value = StretchTValue.On])
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
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-setfill
class SetFillTransformation extends Transformation
    implements ImageTransformation {
  const SetFillTransformation([this.hexColor = '#ffffff']);

  /// fill color
  final String hexColor;

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
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-scale-crop
class ScaleCropTransformation extends ResizeTransformation
    implements EnumTransformation<ScaleCropTypeTValue>, ImageTransformation {
  ScaleCropTransformation(
    Dimensions size, {
    ScaleCropTypeTValue? type,
    this.offset,
    this.center = false,
  })  : value = type,
        super(size);

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

  @override
  String get operation => 'scale_crop';

  @override
  List<String> get params => [
        ...super.params,
        if (value != null) valueAsString,
        if (offset != null) offset.toString() else if (center) 'center',
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
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-preview
class PreviewTransformation extends ResizeTransformation
    implements ImageTransformation {
  PreviewTransformation([Dimensions size = const Dimensions.square(2048)])
      : super(size);

  @override
  String get operation => 'preview';
}

/// Crop an image to fit into specified dimensions, implement optional offsets.
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-crop
class CropTransformation extends ResizeTransformation
    implements ImageTransformation {
  CropTransformation(
    Dimensions size, [
    this.coordinates,
  ]) : super(size);

  final Coordinates? coordinates;

  @override
  String get operation => 'crop';

  @override
  List<String> get params => [
        ...super.params,
        if (coordinates != null) coordinates.toString(),
      ];
}

/// Resize an image to fit into specified dimensions.
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-resize
class ImageResizeTransformation extends ResizeTransformation
    implements ImageTransformation {
  ImageResizeTransformation(Dimensions size) : super(size);
}

/// The overlay operation allows to layer images one over another.
///
/// See https://uploadcare.com/docs/transformations/image/overlay/#overlay
///
/// You can use overlay transformation to source image, see https://uploadcare.com/docs/transformations/image/overlay/#overlay-self
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
          dimensions != null ? dimensions.units == MeasureUnits.Percent : true,
          'Cannot use `MeasureUnits.Pixel` with this transformation',
        ),
        assert(
            opacity != null
                ? dimensions != null &&
                    coordinates != null &&
                    opacity >= 0 &&
                    opacity <= 100
                : true,
            '`opacity` should be in 0..100 range'),
        assert(
          coordinates != null && coordinates.predefined == null
              ? coordinates.offset.units == MeasureUnits.Percent
              : true,
          'Cannot use `MeasureUnits.Pixel` in coordinates with this transformation',
        );

  /// 'self' or UUID of an image to be layered over input. To be recognized by :uuid, that image should be related to any project of your account.
  /// If you specify 'self' transfomation will be applied to source image
  final String imageId;

  /// Linear relative dimensions of the overlay image. The aspect ratio of an overlay is preserved.
  final Dimensions? dimensions;

  /// Relative position of the overlay over your input. By default, an overlay is positioned in the top-left corner of an input.
  /// Coordinates represent an offset along each of the axes in either pixel or percent format.
  /// In general, the coordinate system is similar to the CSS background-position. See [Coordinates].
  final Coordinates? coordinates;

  /// Controls the opacity of the overlay in percent format.
  final int? opacity;

  @override
  String get operation => 'overlay';

  @override
  List<String> get params => [
        imageId,
        if (dimensions != null) dimensions.toString(),
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

enum BlurRegionTValue {
  Region,
  Faces,
}

/// Blurs the specified region of the image by the `radius` factor.
/// The filtering mode is Gaussian Blur, where `radius` parameter sets the blur radius — effect intensity.
/// Technically, `radius` controls the Gaussian Blur standard deviation multiplied by ten.
/// The value of `radius` might come up to 5000, while the default value is determined automatically based on the size of the region.
/// Note, larger `radius` values do not affect the operation performance.
///
/// Blur region: https://uploadcare.com/docs/transformations/image/blur-sharpen/#operation-blur-region
/// Blur faces: https://uploadcare.com/docs/transformations/image/blur-sharpen/#operation-blur-region-faces
class BlurRegionTransformation extends BlurTransformation {
  BlurRegionTransformation({
    this.type = BlurRegionTValue.Region,
    this.dimensions,
    this.coordinates,
    int? radius,
  })  : assert(
          type == BlurRegionTValue.Region
              ? dimensions != null && coordinates != null
              : true,
          '`dimensions` and `coordinates` are required for `BlurRegionTValue.Region`',
        ),
        super(radius);

  /// When [BlurRegionTValue.Faces] is specified the regions are selected automatically by utilizing face detection.
  final BlurRegionTValue type;
  final Dimensions? dimensions;
  final Offsets? coordinates;

  @override
  String get operation => 'blur_region';

  @override
  List<String> get params => [
        if (type == BlurRegionTValue.Faces) 'faces',
        if (type == BlurRegionTValue.Region) ...[
          dimensions!.toString(),
          coordinates!.toString(),
        ],
        ...super.params,
      ];
}

/// See: https://uploadcare.com/docs/transformations/image/blur-sharpen/#operation-blur-mask
class UnsharpMaskingTransformation extends BlurTransformation {
  const UnsharpMaskingTransformation([this.amount = 100, int radius = 10])
      : assert(amount >= -200 && amount <= 100, 'Should be in -200..100 range'),
        super(radius);

  /// - 100 stands for the opaque blur image.
  /// - 0 stands for no changes in the image, the output is equal to the original.
  /// - Any negative number would mean subtracting the difference between the blurred and original images from the original. That is the unsharp masking behavior.
  final int amount;

  @override
  List<String> get params => [
        ...super.params,
        amount.toString(),
      ];
}

/// Filter names
enum FilterTValue {
  Adaris,
  Briaril,
  Calarel,
  Carris,
  Cynarel,
  Cyren,
  Elmet,
  Elonni,
  Enzana,
  Erydark,
  Fenralan,
  Ferand,
  Galen,
  Gavin,
  Gethriel,
  Iorill,
  Iothari,
  Iselva,
  Jadis,
  Lavra,
  Misiara,
  Namala,
  Nerion,
  Nethari,
  Pamaya,
  Sarnar,
  Sedis,
  Sewen,
  Sorahel,
  Sorlen,
  Tarian,
  Thellassan,
  Varriel,
  Varven,
  Vevera,
  Virkas,
  Yedis,
  Yllara,
  Zatvel,
  Zevcen,
}

/// Applies one of predefined photo filters by its [FilterTValue].
/// The way your images look affects their engagement rates.
/// You apply filters thus providing beautiful images consistent across content pieces you publish.
///
/// See https://uploadcare.com/docs/transformations/image/colors/#operation-filter
class FilterTransformation extends EnumTransformation<FilterTValue>
    implements ImageTransformation {
  const FilterTransformation(FilterTValue name, [this.amount = 100])
      : assert(amount >= -100 && amount <= 200, 'Should be in -100..200 range'),
        super(name);

  /// can be set in the range from -100 to 200 and defaults to 100. The :amount of:
  ///
  /// - 0 stands for no changes in the image, the output is equal to the original.
  /// - values in the range from 0 to 100 gradually increase filter strength; 100 makes filters work as designed.
  /// - values over 100 emphasizes filter effect: the strength of applied changes.
  /// - any negative number would mean subtracting the difference between the filtered and original images from the original. That will produce a "negative filter" effect.
  final int amount;

  @override
  String get operation => 'filter';

  @override
  String get valueAsString {
    return value.toString().split('.').last.toLowerCase();
  }

  @override
  List<String> get params => [
        ...super.params,
        amount.toString(),
      ];
}

/// Zoom objects operation is best suited for images with solid or uniform backgrounds.
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-zoom-objects
class ZoomObjectTransformation extends IntTransformation
    implements ImageTransformation {
  const ZoomObjectTransformation(int zoom)
      : assert(zoom >= 0 && zoom <= 100, 'Should be in 0..100 range'),
        super(zoom);

  @override
  String get operation => 'zoom_objects';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorBrightnessTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorBrightnessTransformation(int value)
      : assert(value >= -100 && value <= 100, 'Should be in -100..100 range'),
        super(value);

  @override
  String get operation => 'brightness';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorExposureTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorExposureTransformation(int value)
      : assert(value >= -500 && value <= 500, 'Should be in -500..500 range'),
        super(value);

  @override
  String get operation => 'exposure';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorGammaTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorGammaTransformation(int value)
      : assert(value >= 0 && value <= 1000, 'Should be in 0..1000 range'),
        super(value);

  @override
  String get operation => 'gamma';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorContrastTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorContrastTransformation(int value)
      : assert(value >= -100 && value <= 500, 'Should be in -100..500 range'),
        super(value);

  @override
  String get operation => 'contrast';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorSaturationTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorSaturationTransformation(int value)
      : assert(value >= -100 && value <= 500, 'Should be in -100..500 range'),
        super(value);

  @override
  String get operation => 'saturation';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorVibranceTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorVibranceTransformation(int value)
      : assert(value >= -100 && value <= 500, 'Should be in -100..500 range'),
        super(value);

  @override
  String get operation => 'vibrance';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorWarmthTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorWarmthTransformation(int value)
      : assert(value >= -100 && value <= 100, 'Should be in -100..100 range'),
        super(value);

  @override
  String get operation => 'warmth';
}

enum SrgbTValue {
  Fast,
  Icc,
  KeepProfile,
}

/// The operation sets how Uploadcare behaves depending on different color profiles of uploaded images.
///
/// See https://uploadcare.com/docs/transformations/image/colors/#operation-srgb
class SrgbTransformation extends EnumTransformation<SrgbTValue>
    implements ImageTransformation {
  const SrgbTransformation(SrgbTValue value) : super(value);

  @override
  String get operation => 'srgb';

  @override
  String get valueAsString {
    switch (value) {
      case SrgbTValue.Fast:
        return 'fast';
      case SrgbTValue.Icc:
        return 'icc';
      case SrgbTValue.KeepProfile:
        return 'keep_profile';
      default:
        return '';
    }
  }
}

/// By default, CDN instructs browsers to show images and download other file types.
/// The inline control allows you to change this behavior.
///
/// See https://uploadcare.com/docs/delivery/cdn/#inline
class InlineTransformation extends BooleanTransformation
    implements ImageTransformation {
  const InlineTransformation(bool inline) : super(inline);

  @override
  String get operation => 'inline';
}
