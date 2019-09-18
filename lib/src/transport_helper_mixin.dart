import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:uploadcare_client/src/options_shortcuts_mixin.dart';
import 'package:uploadcare_client/src/transport.dart';

mixin UploadcareTransportHelperMixin on UploadcareOptionsShortcutsMixin {
  UploadcareMultipartRequest createMultipartRequest(
    String method,
    String url, [
    bool authorizeRequest = true,
  ]) =>
      UploadcareMultipartRequest(
        scheme: authorizeRequest ? options.authorizationScheme : null,
        method: method,
        uri: Uri.parse('$url'),
      );

  UploadcareRequest createRequest(
    String method,
    String url, [
    bool authorizeRequest = true,
  ]) =>
      UploadcareRequest(
        scheme: authorizeRequest ? options.authorizationScheme : null,
        method: method,
        uri: Uri.parse('$url'),
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

  Future<Response> resolveStreamedResponseStatusCode(
          FutureOr<StreamedResponse> streamedResponse) async =>
      _resolveResponseStatusCode(Response.fromStream(await streamedResponse));

  Future<Map<String, dynamic>> resolveStreamedResponse(
          FutureOr<StreamedResponse> streamedResponse) =>
      _resolveResponse(resolveStreamedResponseStatusCode(streamedResponse));
}
