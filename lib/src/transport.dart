import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

class UploadcareMultipartRequest extends MultipartRequest {
  UploadcareMultipartRequest({
    @required String method,
    @required Uri uri,
    UploadcareAuthScheme scheme,
  })  : this._scheme = scheme,
        super(method, uri) {
    headers.addAll({'Content-Type': 'application/x-www-form-urlencoded'});
  }

  final UploadcareAuthScheme _scheme;

  @override
  Future<StreamedResponse> send() {
    if (_scheme != null) _scheme.injectAuthorizationData(this);

    return super.send();
  }
}

class UploadcareRequest extends Request {
  UploadcareRequest({
    @required String method,
    @required Uri uri,
    UploadcareAuthScheme scheme,
  })  : _scheme = scheme,
        super(method, uri) {
    headers.addAll({'Content-Type': 'application/json'});
  }

  final UploadcareAuthScheme _scheme;

  @override
  Future<StreamedResponse> send() {
    if (_scheme != null) _scheme.injectAuthorizationData(this);

    return super.send();
  }
}
