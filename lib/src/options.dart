import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';
import 'package:uploadcare_client/src/constants.dart';

class ClientOptions {
  final String uploadUrl;
  final String apiUrl;
  final String cdnUrl;
  final AuthScheme authorizationScheme;
  final bool useSignedUploads;
  final Duration signedUploadsSignatureLifetime;
  final int multipartMaxConcurrentChunkRequests;

  const ClientOptions({
    @required this.authorizationScheme,
    this.uploadUrl = kDefaultUploadEndpoint,
    this.apiUrl = kDefaultRequestEndpoint,
    this.cdnUrl = kDefaultCdnEndpoint,
    this.useSignedUploads = false,
    this.signedUploadsSignatureLifetime = const Duration(minutes: 30),
    this.multipartMaxConcurrentChunkRequests = 3,
  });
}
