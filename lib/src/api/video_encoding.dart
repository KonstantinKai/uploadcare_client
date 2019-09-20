import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/video_encoding_response.dart';
import 'package:uploadcare_client/src/mixins/mixins.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/src/transformations/common.dart';

class UploadcareApiVideoEncoding
    with UploadcareOptionsShortcutsMixin, UploadcareTransportHelperMixin {
  final UploadcareOptions options;

  UploadcareApiVideoEncoding({
    @required this.options,
  }) : assert(options != null);

  Future<VideoEncodingConvertResponse> process(
    List<PathTransformer<VideoTransformation>> transformers, {
    bool storeMode,
  }) async {
    final request =
        createRequest('POST', buildUri('$requestUrl/convert/video/'))
          ..body = jsonEncode({
            'paths':
                transformers.map((transformer) => transformer.path).toList(),
            'store': resolveStoreModeParam(storeMode),
          });

    return VideoEncodingConvertResponse.fromJson(
      await resolveStreamedResponse(request.send()),
    );
  }

  Future<VideoEncodingJobResponse> status(int token) async =>
      VideoEncodingJobResponse.fromJson(
        await resolveStreamedResponse(
          createRequest(
            'GET',
            buildUri('$requestUrl/convert/video/status/$token'),
          ).send(),
        ),
      );

  Stream<VideoEncodingJobResponse> statusAsStream(
    int token, {
    Duration checkInterval = const Duration(seconds: 5),
  }) async* {
    while (true) {
      sleep(checkInterval);
      final response = await status(token);

      yield response;

      if (![
        VideoEncodingJobStatusValue.Processing,
        VideoEncodingJobStatusValue.Pending
      ].contains(response.status)) break;
    }
  }
}
