import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import '../entities/video_encoding.dart';
import '../mixins/mixins.dart';
import '../options.dart';
import '../transformations/base.dart';
import '../transformations/common.dart';
import '../transformations/path_transformer.dart';
import '../transformations/video.dart';

/// Provides API for working with video encoding
class ApiVideoEncoding with OptionsShortcutMixin, TransportHelperMixin {
  @override
  final ClientOptions options;

  ApiVideoEncoding({
    required this.options,
  });

  /// Run a processing job
  ///
  /// [transformers] is a Map with video `id` and list of [VideoTransformation]
  /// When [storeMode] is set to `false`, the outputs will only be available for 24 hours.
  ///
  /// Example:
  /// ```dart
  /// ...
  /// final videoEncoding = ApiVideoEncoding(options);
  ///
  /// final result = await videoEncoding.process({
  ///   'video-id-1': [
  ///     CutTransformation(
  ///       const const Duration(seconds: 10),
  ///       length: const Duration(
  ///         seconds: 30,
  ///       ),
  ///     )
  ///   ],
  ///   'video-id-2': [
  ///     VideoResizeTransformation(const Size(512, 384)),
  ///     VideoThumbsGenerateTransformation(10),
  ///    ]
  /// })
  /// ...
  /// ```
  Future<VideoEncodingConvertEntity> process(
    Map<String, List<VideoTransformation>> transformers, {
    bool? storeMode,
  }) async {
    final request = createRequest('POST', buildUri('$apiUrl/convert/video/'))
      ..body = jsonEncode({
        'paths': transformers.entries.map((entry) {
          assert(() {
            return !entry.value.any((transformation) =>
                transformation is QualityTransformation &&
                transformation.value == QualityTValue.Smart);
          }(), 'QualityTValue.Smart cannot be used with VideoTransformation');

          return PathTransformer('${entry.key}/video',
                  transformations: entry.value
                    ..sort((a, b) =>
                        b is VideoThumbsGenerateTransformation ? -1 : 1))
              .path;
        }).toList(),
        'store': resolveStoreModeParam(storeMode),
      });

    return VideoEncodingConvertEntity.fromJson(
      await resolveStreamedResponse(request.send()),
    );
  }

  /// Checking processing job status
  ///
  /// [token] from [VideoEncodingResultEntity.token]
  Future<VideoEncodingJobEntity> status(
    int token,
  ) async =>
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

    controller.add(response);

    if ([
      VideoEncodingJobStatusValue.Processing,
      VideoEncodingJobStatusValue.Pending
    ].contains(response.status)) {
      Timer(checkInterval,
          () => _statusTimerCallback(token, checkInterval, controller));
      return;
    }

    // ignore: unawaited_futures
    controller.close();
  }

  /// Returns processing job as `Stream`
  ///
  /// [token] from [VideoEncodingResultEntity.token]
  /// [checkInterval] check status interval
  Stream<VideoEncodingJobEntity> statusAsStream(
    int token, {
    Duration checkInterval = const Duration(seconds: 5),
  }) {
    final StreamController<VideoEncodingJobEntity> controller =
        StreamController.broadcast();

    Timer(checkInterval,
        () => _statusTimerCallback(token, checkInterval, controller));

    return controller.stream;
  }
}
