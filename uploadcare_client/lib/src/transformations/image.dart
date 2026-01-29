import '../measures.dart';
import 'base.dart';
import 'common.dart';

enum ImageFormatTValue {
  /// Convert an image to JPEG.
  Jpeg('jpeg'),

  /// Convert an image to PNG.
  Png('png'),

  /// Convert an image to WebP.
  Webp('webp'),

  /// Try converting to WebP or AVIF and fall back to JPEG when a user browser provides no WebP or AVIF support.
  Auto('auto'),

  /// Returns the image in the original format if it is PNG or JPEG, otherwise coerces to PNG or JPEG.
  /// This option is useful when you need to save the image, rather than display it to the end-user.
  Preserve('preserve');

  const ImageFormatTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// Convert an image to one of the supported output formats: [ImageFormatTValue]
///
/// See https://uploadcare.com/docs/transformations/image/compression/#operation-format
class ImageFormatTransformation extends EnumTransformation<ImageFormatTValue>
    implements ImageTransformation {
  const ImageFormatTransformation(ImageFormatTValue super.value);

  @override
  String get valueAsString => value?.toString() ?? '';

  @override
  String get operation => 'format';
}

/// Convert JPEG to Progressive JPEG. Has no effect on non-JPEGs. Does not force image formats to jpeg.
/// if [value] is equal `true` then are using multi-scan rendering.
///
/// See https://uploadcare.com/docs/transformations/image/compression/#operation-progressive
class ProgressiveTransformation extends BooleanTransformation
    implements ImageTransformation {
  const ProgressiveTransformation([super.value = false]);

  @override
  String get operation => 'progressive';
}

/// Instruct Uploadcare CDN whether it should rotate an image according to the EXIF orientation tag or not.
///
/// See https://uploadcare.com/docs/transformations/image/rotate-flip/#operation-autorotate
class AutoRotateTransformation extends BooleanTransformation
    implements ImageTransformation {
  const AutoRotateTransformation([super.value = true]);

  @override
  String get operation => 'autorotate';
}

/// Rotate an image counterclockwise.
/// [value] should be in `-360..360` range
///
/// See https://uploadcare.com/docs/transformations/image/rotate-flip/#operation-rotate
class RotateTransformation extends IntTransformation
    implements ImageTransformation {
  const RotateTransformation(int super.value)
      : assert(value >= -360 && value <= 360, 'Should be in -360..360 range');

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
  const EnhanceTransformation([int super.value = 50])
      : assert(value >= 0 && value <= 100, 'Should be in 0..100 range');

  @override
  String get operation => 'enhance';
}

/// Sharpen an image, might be especially useful with images that were subjected to downscaling.
/// [value] should be in `0..20` range
///
/// See https://uploadcare.com/docs/transformations/image/blur-sharpen/#operation-sharp
class SharpTransformation extends IntTransformation
    implements ImageTransformation {
  const SharpTransformation([int super.value = 5])
      : assert(value >= 0 && value <= 20, 'Should be in 0..20 range');

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
  const BlurTransformation([super.value = 10])
      : assert(value != null ? value >= 0 && value <= 5000 : true,
            'Should be in 0..5000 range');

  @override
  String get operation => 'blur';
}

/// Strip off an ICC profile from an image based on the profile [value] in *kilobytes*.
/// [value] should be positive [int]
///
/// See https://uploadcare.com/docs/transformations/image/colors/#operation-max-icc-size
class MaxIccSizeTransformation extends IntTransformation
    implements ImageTransformation {
  const MaxIccSizeTransformation([int super.value = 10])
      : assert(value >= 0, 'Should be positive int');

  @override
  String get operation => 'max_icc_size';
}

enum StretchTValue {
  /// stretch the source image.
  On('on'),

  /// forbid stretching the source image.
  Off('off'),

  /// forbid stretching the source image, render color-filled frame around.
  Fill('fill');

  const StretchTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// Set the [ImageResizeTransformation] behavior when provided [Size] are greater than the source image dimensions.
/// The directive should come before [ImageResizeTransformation] transformation to give any effect.
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-stretch
class StretchTransformation extends EnumTransformation<StretchTValue>
    implements ImageTransformation {
  const StretchTransformation([StretchTValue super.value = StretchTValue.On]);

  @override
  String get valueAsString => value?.toString() ?? '';

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
  Smart('smart'),

  /// same as [ScaleCropTypeTValue.Smart], face detection, object detection and corner points detection
  SmartFacesObjectsPoints('smart_faces_objects_points'),

  /// face detection, followed by object detection
  SmartFacesObjects('smart_faces_objects'),

  /// face detection, followed by corner points detection
  SmartFacesPoints('smart_faces_points'),

  /// object detection, followed by face detection, followed by corner points detection
  SmartObjectsFacesPoints('smart_objects_faces_points'),

  /// object detection, followed by face detection
  SmartObjectsFaces('smart_objects_faces'),

  /// object detection, followed by corner points detection
  SmartObjectsPoints('smart_objects_points'),

  /// corner points detection or manual region specified by offset parameter
  SmartPoints('smart_points'),

  /// object detection or manual region specified by offset parameter
  SmartObjects('smart_objects'),

  /// face detection or manual region specified by offset parameter
  SmartFaces('smart_faces');

  const ScaleCropTypeTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// Downscale an image along one of the axes (the one with smaller linear size) and crop the rest.
/// The method can be implemented with manual, center-focused or “smart crop” behavior.
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-scale-crop
class ScaleCropTransformation extends ResizeTransformation
    implements EnumTransformation<ScaleCropTypeTValue>, ImageTransformation {
  ScaleCropTransformation(
    super.size, {
    ScaleCropTypeTValue? type,
    this.offset,
    this.center = false,
  }) : value = type;

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
  String get valueAsString => value?.toString() ?? '';
}

/// Resize an image to fit into specified dimensions, proportional.
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-preview
class PreviewTransformation extends ResizeTransformation
    implements ImageTransformation {
  PreviewTransformation([super.size = const Dimensions.square(2048)]);

  @override
  String get operation => 'preview';
}

/// Possible [CropTransformation.tag] values
enum CropTagTValue {
  /// The largest detected face in the image is used as a crop basis.
  Face('face'),

  /// The whole image is used as a crop basis.
  Image('image');

  const CropTagTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// Crop an image to fit into specified dimensions, implement optional offsets.
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-crop
class CropTransformation extends Transformation implements ImageTransformation {
  CropTransformation({
    this.size,
    this.aspectRatio,
    this.coords,
    this.tag,
  }) : assert(
          size != null || aspectRatio != null,
          'One of `size` or `aspectRatio` should be provided',
        );

  final Coordinates? coords;

  final Dimensions? size;

  /// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-crop-aspect-ratio
  final AspectRatio? aspectRatio;

  /// Crops the image to the object specified by the [tag] parameter. The found object fits into the given aspect ratio if [aspectRatio] is specified.
  ///
  /// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-crop-tags
  final CropTagTValue? tag;

  @override
  String get operation => 'crop';

  @override
  List<String> get params => [
        if (tag != null) tag.toString(),
        if (size != null) size.toString(),
        if (aspectRatio != null) aspectRatio.toString(),
        if (coords != null) coords.toString(),
      ];
}

/// Resize an image to fit into specified dimensions.
///
/// See https://uploadcare.com/docs/transformations/image/resize-crop/#operation-resize
class ImageResizeTransformation extends ResizeTransformation
    implements ImageTransformation {
  ImageResizeTransformation(super.size, [this.useSmartResize = false]);

  final bool useSmartResize;

  @override
  String get operation => useSmartResize ? 'smart_resize' : super.operation;
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
            '`opacity` should be in 0..100 range');

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
  bool operator ==(Object other) =>
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
  const UnsharpMaskingTransformation([this.amount = 100, int super.radius])
      : assert(amount >= -200 && amount <= 100, 'Should be in -200..100 range');

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
  const FilterTransformation(FilterTValue super.name, [this.amount = 100])
      : assert(amount >= -100 && amount <= 200, 'Should be in -100..200 range');

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
  const ZoomObjectTransformation(int super.zoom)
      : assert(zoom >= 0 && zoom <= 100, 'Should be in 0..100 range');

  @override
  String get operation => 'zoom_objects';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorBrightnessTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorBrightnessTransformation(int super.value)
      : assert(value >= -100 && value <= 100, 'Should be in -100..100 range');

  @override
  String get operation => 'brightness';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorExposureTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorExposureTransformation(int super.value)
      : assert(value >= -500 && value <= 500, 'Should be in -500..500 range');

  @override
  String get operation => 'exposure';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorGammaTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorGammaTransformation(int super.value)
      : assert(value >= 0 && value <= 1000, 'Should be in 0..1000 range');

  @override
  String get operation => 'gamma';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorContrastTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorContrastTransformation(int super.value)
      : assert(value >= -100 && value <= 500, 'Should be in -100..500 range');

  @override
  String get operation => 'contrast';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorSaturationTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorSaturationTransformation(int super.value)
      : assert(value >= -100 && value <= 500, 'Should be in -100..500 range');

  @override
  String get operation => 'saturation';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorVibranceTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorVibranceTransformation(int super.value)
      : assert(value >= -100 && value <= 500, 'Should be in -100..500 range');

  @override
  String get operation => 'vibrance';
}

/// See https://uploadcare.com/docs/transformations/image/colors/#image-colors-operations
class ColorWarmthTransformation extends IntTransformation
    implements ImageTransformation {
  const ColorWarmthTransformation(int super.value)
      : assert(value >= -100 && value <= 100, 'Should be in -100..100 range');

  @override
  String get operation => 'warmth';
}

enum SrgbTValue {
  Fast('fast'),
  Icc('icc'),
  KeepProfile('keep_profile');

  const SrgbTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// The operation sets how Uploadcare behaves depending on different color profiles of uploaded images.
///
/// See https://uploadcare.com/docs/transformations/image/colors/#operation-srgb
class SrgbTransformation extends EnumTransformation<SrgbTValue>
    implements ImageTransformation {
  const SrgbTransformation(SrgbTValue super.value);

  @override
  String get operation => 'srgb';

  @override
  String get valueAsString => value?.toString() ?? '';
}

enum StripMetaTValue {
  /// The default behavior when no strip_meta operation is applied. No meta information will be added to the processed file.
  All('all'),

  /// Copies the EXIF from the original file. The orientation tag will be set to 1 (normal orientation).
  None('none'),

  /// Copies the EXIF from the original file but skips geolocation. The orientation tag will be set to 1 (normal orientation).
  Sensitive('sensitive');

  const StripMetaTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// The original image often comes with additional information built into the image file.
/// In most cases, this information doesn't affect image rendering and thus can be safely stripped from the processed images.
/// However, you can control this behavior with this option.
/// This could be helpful if you want to keep meta information in the processed image.
///
/// Currently, you can keep only EXIF meta information. Other storages, such as XMP or IPTC, will always be stripped.
///
/// See https://uploadcare.com/docs/transformations/image/compression/#meta-information-control
class StripMetaTransformation extends EnumTransformation<StripMetaTValue>
    implements ImageTransformation {
  const StripMetaTransformation([super.value]);

  @override
  String get operation => 'strip_meta';

  @override
  String get valueAsString => value?.toString() ?? '';
}

/// Any image transformation CDN URL is valid with an SVG file.
/// Most operations don't affect the response SVG body, while geometric operations (crop, preview, resize, scale_crop) change SVG attributes and work as expected.
/// To apply full range of operations on SVG file, it should be rasterized by applying /rasterize/ operation.
///
/// Note: Operation is safe to apply to any image. Not SVG images won't be affected by this operation.
///
/// Note: SVGs uploaded before May 26, 2021 still have `is_image: false` and adding processing operations to them will result in error.
/// Contact support to batch process previously uploaded files.
///
/// See https://uploadcare.com/docs/transformations/image/#svg
class RasterizeTransformation extends NullParamTransformation
    implements ImageTransformation {
  @override
  String get operation => 'rasterize';
}

class BorderRadiusTransformation extends Transformation
    implements ImageTransformation {
  const BorderRadiusTransformation({
    required this.radii,
    this.verticalRadii,
  });

  final Radii radii;
  final Radii? verticalRadii;

  @override
  String get operation => 'border_radius';

  @override
  List<String> get params => [
        radii.toString(),
        if (verticalRadii != null) verticalRadii.toString(),
      ];
}

/// The rect operation allows to draw a solid color rectangle on top of an image.
class RectOverlayTransformation extends Transformation
    implements ImageTransformation {
  RectOverlayTransformation({
    required this.color,
    required this.relativeDimensions,
    required this.relativeCoordinates,
  })  : assert(relativeCoordinates.units == MeasureUnits.Percent,
            '`relativeCoordinates` should be specified in percent'),
        assert(relativeDimensions.units == MeasureUnits.Percent,
            '`relativeDimensions` should be specified in percent');

  @override
  String get operation => 'rect';

  /// Color of the rectangle. It can have alpha channel specified for transparency
  final String color;

  /// Linear dimensions of the rectangle
  final Dimensions relativeDimensions;

  /// Posiiton of the rectangle over your input
  final Offsets relativeCoordinates;

  @override
  List<String> get params => [
        color,
        relativeDimensions.toString(),
        relativeCoordinates.toString(),
      ];
}

/// NOTE: Permissions
///
/// Contact sales to enable text overlay features for your project.
///
/// Text overlay operation permits arbitrary, user provided content.
/// This might be used for vandalism and serving of offensive and misleading messages from customer domain.
/// Therefore, we recommend using it along with signed URLs.
///
/// The text operation allows placing arbitrary text on top of an image.
class TextOverlayTransformation extends Transformation
    implements ImageTransformation {
  TextOverlayTransformation({
    required this.relativeDimensions,
    required this.relativeCoordinates,
    required this.text,
    this.font,
    this.align,
    this.background,
  })  : assert(relativeCoordinates.units == MeasureUnits.Percent,
            '`relativeCoordinates` should be specified in percent'),
        assert(relativeDimensions.units == MeasureUnits.Percent,
            '`relativeDimensions` should be specified in percent');

  /// Linear dimensions of area allocated for text placement. These dimensions are used for text alignment, and width affects line wrapping
  final Dimensions relativeDimensions;

  /// Position of text area. Coordinates represent an offset along each of the axes in either pixel or percent format. In general, the coordinate system is similar to the CSS background-position.
  /// For example, -/text/90px10p/10%,90%/... places text in bottom left corner
  final Offsets relativeCoordinates;

  /// Actual text to be placed
  final String text;
  final TextFontTransformation? font;
  final TextAlignTransformation? align;
  final TextBackgroundBoxTransformation? background;

  @override
  String get operation => 'text';

  @override
  List<String> get params => [
        if (font != null) '${font.toString()}/-',
        if (background != null) '${background.toString()}/-',
        if (align != null) '${align.toString()}/-',
        operation,
        relativeDimensions.toString(),
        relativeCoordinates.toString(),
        Uri.encodeComponent(text),
      ];

  @override
  String toString() {
    return params.join('/');
  }
}

/// NOTE: Use only with [TextOverlayTransformation]
class TextAlignTransformation extends Transformation
    implements ImageTransformation {
  const TextAlignTransformation({
    required this.hAlign,
    required this.vAlign,
  });

  final Position hAlign;
  final Position vAlign;

  @override
  String get operation => 'text_align';

  @override
  List<String> get params => [
        hAlign.toString(),
        vAlign.toString(),
      ];
}

/// Font weight for text overlay
///
/// See https://uploadcare.com/docs/transformations/image/overlay/#font-properties
enum TextFontWeight {
  Regular('regular'),
  Bold('bold');

  const TextFontWeight(this._value);
  final String _value;

  @override
  String toString() => _value;
}

/// Font style for text overlay
///
/// See https://uploadcare.com/docs/transformations/image/overlay/#font-properties
enum TextFontStyle {
  Normal('normal'),
  Italic('italic');

  const TextFontStyle(this._value);
  final String _value;

  @override
  String toString() => _value;
}

/// Font family for text overlay
///
/// See https://uploadcare.com/docs/transformations/image/overlay/#font-properties
enum TextFontFamily {
  DejaVu('DejaVu'),
  DejaVuMono('DejaVuMono'),
  DejaVuSerif('DejaVuSerif'),
  Noto('Noto'),
  NotoMono('NotoMono'),
  NotoSerif('NotoSerif');

  const TextFontFamily(this._value);
  final String _value;

  @override
  String toString() => _value;
}

/// NOTE: Use only with [TextOverlayTransformation]
///
/// The font operation allows to configure weight, style, size, color, and family.
/// Parameters must follow this order: reset, weight, style, size, color, family.
/// You can skip any parameters, but the ones you include must maintain this order.
///
/// See https://uploadcare.com/docs/transformations/image/overlay/#font-properties
class TextFontTransformation extends Transformation
    implements ImageTransformation {
  const TextFontTransformation({
    this.reset,
    this.weight,
    this.style,
    this.size,
    this.color,
    this.family,
  }) : assert(
          reset != null ||
              weight != null ||
              style != null ||
              size != null ||
              color != null ||
              family != null,
          'At least one font parameter must be specified',
        );

  /// Resets font properties to default values
  final bool? reset;

  /// Font weight
  final TextFontWeight? weight;

  /// Font style
  final TextFontStyle? style;

  /// Font size in pixels
  final int? size;

  /// Font color in hexadecimal notation with optional transparency. Example: `99ff99, 9f9, 99ff9920`
  final String? color;

  /// Font family
  final TextFontFamily? family;

  @override
  String get operation => 'font';

  @override
  List<String> get params => [
        if (reset == true) 'reset',
        if (weight != null) weight.toString(),
        if (style != null) style.toString(),
        if (size != null) size.toString(),
        if (color != null) color!,
        if (family != null) family.toString(),
      ];
}

enum TextBackgroundBoxTValue {
  /// Disabled
  None('none'),

  /// One rectangle, under actual text
  Fit('fit'),

  /// Separate rectangle under each line
  Line('line'),

  /// Fill all space, allocated by [TextOverlayTransformation.relativeDimensions]
  Fill('fill');

  const TextBackgroundBoxTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// NOTE: Use only with [TextOverlayTransformation]
class TextBackgroundBoxTransformation extends Transformation
    implements ImageTransformation {
  const TextBackgroundBoxTransformation({
    required this.mode,
    required this.color,
    required this.padding,
  });

  @override
  String get operation => 'text_box';

  /// How background is placed
  final TextBackgroundBoxTValue mode;

  /// The background color in hexadecimal notation with optional transparency
  final String color;

  /// Increase background size by specified amount in pixels
  final int padding;

  @override
  List<String> get params => [
        mode.toString(),
        color,
        padding.toString(),
      ];
}
