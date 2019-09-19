import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

const String _kDefaultUploadEndpoint = 'https://upload.uploadcare.com';
const String _kDefaultRequestEndpoint = 'https://api.uploadcare.com';

class UploadcareOptions {
  const UploadcareOptions({
    @required this.authorizationScheme,
    this.uploadApiUrl = _kDefaultUploadEndpoint,
    this.requestApiUrl = _kDefaultRequestEndpoint,
  });

  final String uploadApiUrl;
  final String requestApiUrl;
  final UploadcareAuthScheme authorizationScheme;
}
