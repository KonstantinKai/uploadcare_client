import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/video_encoding.dart';
import 'package:uploadcare_client/src/mixins/mixins.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

class ApiVideoEncoding with OptionsShortcutMixin, TransportHelperMixin {
  final ClientOptions options;

  ApiVideoEncoding({
    @required this.options,
  }) : assert(options != null);

  Future<VideoEncodingConvertEntity> process(
    Map<String, List<VideoTransformation>> transformers, {
    bool storeMode,
  }) async {
    final request = createRequest('POST', buildUri('$apiUrl/convert/video/'))
      ..body = jsonEncode({
        'paths': transformers.entries
            .map((entry) =>
                PathTransformer(entry.key, transformations: entry.value).path)
            .toList(),
        'store': resolveStoreModeParam(storeMode),
      });

    return VideoEncodingConvertEntity.fromJson(
      await resolveStreamedResponse(request.send()),
    );
  }

  Future<VideoEncodingJobEntity> status(int token) async =>
      VideoEncodingJobEntity.fromJson(
        await resolveStreamedResponse(
          createRequest(
            'GET',
            buildUri('$apiUrl/convert/video/status/$token'),
          ).send(),
        ),
      );

  Stream<VideoEncodingJobEntity> statusAsStream(
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
