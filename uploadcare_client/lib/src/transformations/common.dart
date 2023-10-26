import '../measures.dart';
import 'base.dart';
import 'image.dart';
import 'video.dart';

enum QualityTValue {
  /// Lowest visual quality yet minimal loading times; smaller than [QualityTValue.Lighter].
  Lightest('lightest'),

  /// Saves traffic without a significant subjective quality loss; smaller file size compared to [QualityTValue.Normal].
  Lighter('lighter'),

  /// Suits most cases.
  Normal('normal'),

  /// Better video quality, larger file size compared to [QualityTValue.Normal].
  Better('better'),

  /// Useful when you want to get perfect quality without paying much attention to file sizes; larger than [QualityTValue.Better] maximum size.
  Best('best'),

  /// Automatically set optimal image compression and format settings to preserve visual quality while minimizing the file size, content-aware.
  /// Only for image transformation
  Smart('smart'),

  /// Similar to [Smart], yet optimized for double pixel density.
  SmartRetina('smart_retina');

  const QualityTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// Sets the level of source quality that affects file sizes and hence loading times and volumes of generated traffic.
class QualityTransformation extends EnumTransformation<QualityTValue>
    implements ImageTransformation, VideoTransformation {
  QualityTransformation([QualityTValue super.value = QualityTValue.Normal]);

  @override
  String get valueAsString => value.toString();

  @override
  String get operation => 'quality';
}

/// Base class for resize-related transformations
class ResizeTransformation extends Transformation {
  ResizeTransformation(this.size)
      : assert(
          size.width > -1
              ? size.width <= 5000
              : true && size.height > -1
                  ? size.height <= 5000
                  : true,
          'Max transform dimension is 5000x5000 in jpeg format',
        ),
        assert(
          size.units != MeasureUnits.Percent,
          'Cannot use `MeasureUnits.Percent` with this transformation',
        );

  final Dimensions size;

  @override
  String get operation => 'resize';

  @override
  List<String> get params => [size.toString()];
}

const _kGifToVideoAllowedTransfomations = <Type>[
  VideoFormatTransformation,
  QualityTransformation,
  PreviewTransformation,
  ResizeTransformation,
  CropTransformation,
  ScaleCropTransformation,
];

/// GIF to Video conversion that provides better loading times thus reducing your bounce rate.
/// The feature is available on paid plans only. Converts GIF files to video on the fly.
/// You can change output format with [VideoFormatTransformation] and change video quality with [QualityTransformation]
///
/// Example:
/// ```dart
/// CdnFile('gif-id-1')
///   ..transform(GifToVideoTransformation([
///     VideoFormatTransformation(VideoFormatTValue.Mp4),
///     QualityTransformation(QualityTValue.Best),
///   ]))
/// ```
class GifToVideoTransformation extends Transformation {
  GifToVideoTransformation([this.transformations = const []])
      : assert(
          transformations.isNotEmpty
              ? transformations.every((transformation) =>
                  _kGifToVideoAllowedTransfomations
                      .contains(transformation.runtimeType))
              : true,
          'You can apply only $_kGifToVideoAllowedTransfomations transformations',
        );

  final List<Transformation> transformations;

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

/// Returns file-related information, such as image dimensions or geotagging data in the JSON format.
///
/// See https://uploadcare.com/docs/delivery/cdn/#file-info
class JsonFileInfoTransformation extends NullParamTransformation {
  @override
  String get operation => 'json';
}

/// Get file info as `application/javascript`
///
/// /See https://uploadcare.com/docs/delivery/cdn/#operation-jsonp
class JsonpFileInfoTransformation extends NullParamTransformation {
  @override
  String get operation => 'jsonp';
}

/// By default, CDN instructs browsers to show images and download other file types.
/// The inline control allows you to change this behavior.
///
/// See https://uploadcare.com/docs/delivery/cdn/#inline
class InlineTransformation extends BooleanTransformation {
  const InlineTransformation(super.inline);

  @override
  String get operation => 'inline';
}

/// You can set an optional filename that users will see instead of the original name
///
/// See https://uploadcare.com/docs/delivery/cdn/#cdn-filename
class ChangeFilenameTransformation extends NullParamTransformation {
  ChangeFilenameTransformation(this.filename)
      : assert(filename.isNotEmpty, 'New filename cannot be empty');

  final String filename;

  @override
  String get delimiter => '';

  @override
  String get operation => filename;
}
