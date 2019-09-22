import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/api/cdn_group.dart';
import 'package:uploadcare_client/src/api/cdn_image.dart';
import 'package:uploadcare_client/src/api/cdn_video.dart';
import 'package:uploadcare_client/src/api/files.dart';
import 'package:uploadcare_client/src/api/groups.dart';
import 'package:uploadcare_client/src/api/upload.dart';
import 'package:uploadcare_client/src/api/video_encoding.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

class UploadcareClient {
  final ClientOptions options;
  final ApiUpload upload;
  final ApiFiles files;
  final ApiVideoEncoding videoEncoding;
  final ApiGroups groups;

  UploadcareClient({
    @required this.options,
  })  : upload = ApiUpload(options: options),
        files = ApiFiles(options: options),
        videoEncoding = ApiVideoEncoding(options: options),
        groups = ApiGroups(options: options);

  factory UploadcareClient.withSimpleAuth({
    @required String publicKey,
    @required String privateKey,
    String apiVersion,
  }) =>
      UploadcareClient(
        options: ClientOptions(
          authorizationScheme: AuthSchemeSimple(
            apiVersion: apiVersion,
            publicKey: publicKey,
            privateKey: privateKey,
          ),
        ),
      );

  CdnImage createCdnImage(String id) => CdnImage(
        options: options,
        id: id,
      );

  CdnVideo createCdnVideo(String id) => CdnVideo(
        options: options,
        id: id,
      );

  CdnGroup createCdnGroup(String id) => CdnGroup(
        id: id,
        options: options,
      );
}
