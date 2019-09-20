import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

const String _kDefaultUploadEndpoint = 'https://upload.uploadcare.com';
const String _kDefaultRequestEndpoint = 'https://api.uploadcare.com';
const String _kDefaultCdnEndpoint = 'https://ucarecdn.com';

class UploadcareOptions {
  const UploadcareOptions({
    @required this.authorizationScheme,
    this.uploadApiUrl = _kDefaultUploadEndpoint,
    this.requestApiUrl = _kDefaultRequestEndpoint,
    this.cdnApiUrl = _kDefaultCdnEndpoint,
    this.useSignedUploads = false,
    this.signedUploadsSignatureLifetime = const Duration(minutes: 30),
  });

  final String uploadApiUrl;
  final String requestApiUrl;
  final String cdnApiUrl;
  final UploadcareAuthScheme authorizationScheme;
  final bool useSignedUploads;
  final Duration signedUploadsSignatureLifetime;
}
