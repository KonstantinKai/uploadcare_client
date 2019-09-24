import 'package:flutter/painting.dart';
import 'package:uploadcare_client/src/api/cdn_image.dart';
import 'package:uploadcare_client/src/constants.dart';
import 'package:uploadcare_client/src/transformations/base.dart';

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

  @override
  ImageStreamCompleter load(NetworkImage key) => _provider.load(key);

  @override
  Future<NetworkImage> obtainKey(ImageConfiguration configuration) =>
      _provider.obtainKey(configuration);
}
