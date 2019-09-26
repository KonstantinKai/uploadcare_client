import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:flutter_uploadcare_client/src/mixins/mixins.dart';
import 'package:flutter_uploadcare_client/src/transport.dart';

mixin TransportHelperMixin on OptionsShortcutMixin {
  @protected
  UcMultipartRequest createMultipartRequest(
    String method,
    Uri uri, [
    bool authorizeRequest = true,
  ]) =>
      UcMultipartRequest(
        scheme: authorizeRequest ? options.authorizationScheme : null,
        method: method,
        uri: uri,
      );

  @protected
  UcRequest createRequest(
    String method,
    Uri uri, [
    bool authorizeRequest = true,
  ]) =>
      UcRequest(
        scheme: authorizeRequest ? options.authorizationScheme : null,
        method: method,
        uri: uri,
      );

  Future<Response> _resolveResponseStatusCode(FutureOr<Response> resp) async {
    final response = await resp;

    if (response.statusCode > 201)
      throw ClientException(
          'Unexpected status ${response.statusCode} from "${response.request.url}" with reason "${String.fromCharCodes(response.bodyBytes)}"');

    return response;
  }

  Future<Map<String, dynamic>> _resolveResponse(FutureOr<Response> resp) async {
    final response = await _resolveResponseStatusCode(resp);

    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw FormatException('Invalid JSON format from ${response.request.url}');
    }
  }

  @protected
  Future<Response> resolveStreamedResponseStatusCode(
          FutureOr<StreamedResponse> streamedResponse) async =>
      _resolveResponseStatusCode(Response.fromStream(await streamedResponse));

  @protected
  Future<Map<String, dynamic>> resolveStreamedResponse(
          FutureOr<StreamedResponse> streamedResponse) =>
      _resolveResponse(resolveStreamedResponseStatusCode(streamedResponse));

  @protected
  Uri buildUri(String url, [Map<String, dynamic> params = const {}]) {
    final uri = Uri.parse(url);

    if (params.isEmpty) return uri;

    return uri.replace(queryParameters: params);
  }

  @protected
  String resolveStoreModeParam(bool storeMode) =>
      storeMode != null ? storeMode ? '1' : '0' : 'auto';
}
