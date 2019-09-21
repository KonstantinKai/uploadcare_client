import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

const String _kDefaultUploadEndpoint = 'https://upload.uploadcare.com';
const String _kDefaultRequestEndpoint = 'https://api.uploadcare.com';
const String _kDefaultCdnEndpoint = 'https://ucarecdn.com';

class ClientOptions {
  final String uploadUrl;
  final String apiUrl;
  final String cdnUrl;
  final AuthScheme authorizationScheme;
  final bool useSignedUploads;
  final Duration signedUploadsSignatureLifetime;

  const ClientOptions({
    @required this.authorizationScheme,
    this.uploadUrl = _kDefaultUploadEndpoint,
    this.apiUrl = _kDefaultRequestEndpoint,
    this.cdnUrl = _kDefaultCdnEndpoint,
    this.useSignedUploads = false,
    this.signedUploadsSignatureLifetime = const Duration(minutes: 30),
  });
}
