import 'dart:convert';

import 'package:meta/meta.dart';

import '../entities/convert.dart';
import '../entities/document_converting.dart';
import '../mixins/options_shortcuts_mixin.dart';
import '../mixins/transport_helper_mixin.dart';
import '../options.dart';
import '../transformations/base.dart';
import '../transformations/path_transformer.dart';
import 'convert_mixin.dart';

/// Provides API for working with document converting
///
/// See https://uploadcare.com/api-refs/rest-api/v0.6.0/#operation/documentConvert
class ApiDocumentConverting
    with
        OptionsShortcutMixin,
        TransportHelperMixin,
        ConvertMixin<DocumentConvertingResultEntity, DocumentTransformation> {
  @override
  final ClientOptions options;

  ApiDocumentConverting({
    required this.options,
  });

  @override
  Future<ConvertEntity<DocumentConvertingResultEntity>> process(
    Map<String, List<DocumentTransformation>> transformers, {
    bool? storeMode,
  }) async {
    final request = createRequest('POST', buildUri('$apiUrl/convert/document/'))
      ..body = jsonEncode({
        'paths': transformToPaths(transformers),
        'store': resolveStoreModeParam(storeMode),
      });

    return ConvertEntity.fromJson(
      await resolveStreamedResponse(request.send()),
      DocumentConvertingResultEntity.fromJson,
    );
  }

  @visibleForTesting
  List<String> transformToPaths(
      Map<String, List<DocumentTransformation>> transformers) {
    return transformers.entries.map((entry) {
      return PathTransformer('${entry.key}/document',
              transformations: entry.value)
          .path;
    }).toList();
  }

  @override
  Future<ConvertJobEntity<DocumentConvertingResultEntity>> status(
    int token,
  ) async =>
      ConvertJobEntity.fromJson(
        await resolveStreamedResponse(
          createRequest(
            'GET',
            buildUri('$apiUrl/convert/document/status/$token/'),
          ).send(),
        ),
        DocumentConvertingResultEntity.fromJson,
      );
}
