import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/video_encoding.dart';
import 'package:uploadcare_client/src/mixins/mixins.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';
import 'package:uploadcare_client/src/transformations/video.dart';

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
            .map((entry) => PathTransformer('${entry.key}/video',
                    transformations: entry.value
                      ..sort((a, b) =>
                          b is VideoThumbsGenerateTransformation ? -1 : 1))
                .path)
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
            buildUri('$apiUrl/convert/video/status/$token/'),
          ).send(),
        ),
      );

  Future<void> _statusTimerCallback(
    int token,
    Duration checkInterval,
    StreamController<VideoEncodingJobEntity> controller,
  ) async {
    final response = await status(token);

    if (response.status == VideoEncodingJobStatusValue.Failed)
      return controller.addError(ClientException(response.errorMessage));

    controller.add(response);

    if ([
      VideoEncodingJobStatusValue.Processing,
      VideoEncodingJobStatusValue.Pending
    ].contains(response.status))
      return Timer(checkInterval,
          () => _statusTimerCallback(token, checkInterval, controller));

    controller.close();
  }

  Stream<VideoEncodingJobEntity> statusAsStream(
    int token, {
    Duration checkInterval = const Duration(seconds: 5),
  }) {
    final StreamController<VideoEncodingJobEntity> controller =
        StreamController();

    Timer(checkInterval,
        () => _statusTimerCallback(token, checkInterval, controller));

    return controller.stream;
  }
}
