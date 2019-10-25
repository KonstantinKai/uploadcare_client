import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

mixin _AuthorizedRequestMixin on BaseRequest {
  AuthScheme get scheme;

  void authorize() {
    if (scheme != null) scheme.authorizeRequest(this);
  }
}

mixin _CancelableRequestMixin on BaseRequest, _AuthorizedRequestMixin {
  final Client _client = Client();

  void cancel() => _client.close();

  @override
  Future<StreamedResponse> send() async {
    authorize();

    try {
      var response = await _client.send(this);
      var stream = _onDone(response.stream, _client.close);
      return StreamedResponse(
        ByteStream(stream),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (_) {
      _client.close();
      rethrow;
    }
  }

  Stream<T> _onDone<T>(Stream<T> stream, void onDone()) =>
      stream.transform(StreamTransformer.fromHandlers(handleDone: (sink) {
        sink.close();
        onDone();
      }));
}

class UcMultipartRequest extends MultipartRequest
    with _AuthorizedRequestMixin, _CancelableRequestMixin {
  UcMultipartRequest({
    @required String method,
    @required Uri uri,
    this.scheme,
  }) : super(method, uri) {
    headers.addAll(
        {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'});
  }

  final AuthScheme scheme;
}

class UcRequest extends Request
    with _AuthorizedRequestMixin, _CancelableRequestMixin {
  UcRequest({
    @required String method,
    @required Uri uri,
    this.scheme,
  }) : super(method, uri) {
    headers.addAll({HttpHeaders.contentTypeHeader: 'application/json'});
  }

  final AuthScheme scheme;
}
