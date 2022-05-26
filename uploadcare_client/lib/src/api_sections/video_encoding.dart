import 'dart:convert';
import 'package:meta/meta.dart';

import '../entities/convert.dart';
import '../entities/video_encoding.dart';
import '../mixins/mixins.dart';
import '../options.dart';
import '../transformations/base.dart';
import '../transformations/common.dart';
import '../transformations/path_transformer.dart';
import '../transformations/video.dart';
import 'convert_mixin.dart';

/// Provides API for working with video encoding
///
/// See https://uploadcare.com/api-refs/rest-api/v0.6.0/#operation/videoConvert
class ApiVideoEncoding
    with
        OptionsShortcutMixin,
        TransportHelperMixin,
        ConvertMixin<VideoEncodingResultEntity, VideoTransformation> {
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
  @override
  Future<ConvertEntity<VideoEncodingResultEntity>> process(
    Map<String, List<VideoTransformation>> transformers, {
    bool? storeMode,
  }) async {
    final request = createRequest('POST', buildUri('$apiUrl/convert/video/'))
      ..body = jsonEncode({
        'paths': transformToPaths(transformers),
        'store': resolveStoreModeParam(storeMode),
      });

    return ConvertEntity.fromJson(
      await resolveStreamedResponse(request.send()),
      VideoEncodingResultEntity.fromJson,
    );
  }

  @visibleForTesting
  List<String> transformToPaths(
      Map<String, List<VideoTransformation>> transformers) {
    return transformers.entries.map((entry) {
      assert(() {
        return !entry.value.any((transformation) =>
            transformation is QualityTransformation &&
            [QualityTValue.Smart, QualityTValue.SmartRetina]
                .contains(transformation.value));
      }(), '"smart" value cannot be used with VideoTransformation');

      return PathTransformer('${entry.key}/video',
              transformations: entry.value
                ..sort(
                    (a, b) => b is VideoThumbsGenerateTransformation ? -1 : 1))
          .path;
    }).toList();
  }

  /// Checking processing job status
  ///
  /// [token] from [ConvertResultEntity.token]
  @override
  Future<ConvertJobEntity<VideoEncodingResultEntity>> status(
    token,
  ) async =>
      ConvertJobEntity.fromJson(
        await resolveStreamedResponse(
          createRequest(
            'GET',
            buildUri('$apiUrl/convert/video/status/$token/'),
          ).send(),
        ),
        VideoEncodingResultEntity.fromJson,
      );
}
