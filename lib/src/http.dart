import 'package:http/http.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

class UploadcareHttpClient extends MultipartRequest {
  UploadcareHttpClient({
    String method,
    Uri uri,
    UploadcareAuthScheme scheme,
    this.skipAuthorization = false,
  })  : this._scheme = scheme,
        super(method, uri);

  final UploadcareAuthScheme _scheme;
  final bool skipAuthorization;

  @override
  Future<StreamedResponse> send() {
    if (!skipAuthorization) _scheme.injectAuthorizationData(this);

    return super.send();
  }
}
