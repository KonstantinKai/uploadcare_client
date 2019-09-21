import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

class UcMultipartRequest extends MultipartRequest {
  UcMultipartRequest({
    @required String method,
    @required Uri uri,
    AuthScheme scheme,
  })  : this._scheme = scheme,
        super(method, uri) {
    headers.addAll({'Content-Type': 'application/x-www-form-urlencoded'});
  }

  final AuthScheme _scheme;

  @override
  Future<StreamedResponse> send() {
    if (_scheme != null) _scheme.authorizeRequest(this);

    return super.send();
  }
}

class UcRequest extends Request {
  UcRequest({
    @required String method,
    @required Uri uri,
    AuthScheme scheme,
  })  : _scheme = scheme,
        super(method, uri) {
    headers.addAll({'Content-Type': 'application/json'});
  }

  final AuthScheme _scheme;

  @override
  Future<StreamedResponse> send() {
    if (_scheme != null) _scheme.authorizeRequest(this);

    return super.send();
  }
}
