import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/api/cdn_image.dart';
import 'package:uploadcare_client/src/api/cdn_video.dart';
import 'package:uploadcare_client/src/api/manager.dart';
import 'package:uploadcare_client/src/api/upload.dart';
import 'package:uploadcare_client/src/api/video_encoding.dart';
import 'package:uploadcare_client/src/options.dart';

class UploadcareClient {
  UploadcareClient({
    @required this.options,
  })  : upload = UploadcareApiUpload(options: options),
        manager = UploadcareApiManager(options: options),
        videoEncoding = UploadcareApiVideoEncoding(options: options);

  final UploadcareOptions options;
  final UploadcareApiUpload upload;
  final UploadcareApiManager manager;
  final UploadcareApiVideoEncoding videoEncoding;

  UploadcareCdnImage createCdnImage(String id) => UploadcareCdnImage(
        options: options,
        id: id,
      );

  UploadcareCdnVideo createCdnVideo(String id) => UploadcareCdnVideo(
        options: options,
        id: id,
      );
}
