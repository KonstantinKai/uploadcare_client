import 'package:flutter/painting.dart';
import 'package:uploadcare_client/src/api_sections/api_sections.dart';
import 'package:uploadcare_client/src/constants.dart';
import 'package:uploadcare_client/src/transformations/base.dart';

/// Constructs right `Uploadcare CND url` by `id` & provided `transformations` if any
///
/// Uses [NetworkImage] to fetch image from `Uploadcare CDN`
/// Example:
/// ```dart
/// Image(
///   fit: BoxFit.contain,
///   image: UploadcareImageProvider(
///     _fileInfo.id,
///     transformations: [
///       BlurTransformation(50),
///       GrayscaleTransformation(),
///       InvertTransformation(),
///       ImageResizeTransformation(Size.square(58))
///     ],
///   ),
/// )
/// ```
class UploadcareImageProvider extends ImageProvider<NetworkImage> {
  UploadcareImageProvider(
    String id, {
    String cdnUrl = kDefaultCdnEndpoint,
    List<ImageTransformation> transformations = const [],
    double scale = 1.0,
    Map<String, String> headers = const {},
  }) : _cdnImage = CdnImage(
          id,
          cdnUrl: cdnUrl,
        )..transformAll(transformations) {
    _provider = NetworkImage(
      _cdnImage.url,
      scale: scale,
      headers: headers,
    );
  }

  final CdnImage _cdnImage;
  NetworkImage _provider;

  /// @nodoc
  @override
  ImageStreamCompleter load(NetworkImage key) => _provider.load(key);

  /// @nodoc
  @override
  Future<NetworkImage> obtainKey(ImageConfiguration configuration) =>
      _provider.obtainKey(configuration);
}
