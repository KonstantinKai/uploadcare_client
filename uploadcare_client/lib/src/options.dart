import 'authorization/scheme.dart';
import 'constants.dart';

/// Uploadcare client options
class ClientOptions {
  /// Uploadcare upload URL
  final String uploadUrl;

  /// Uploadcare api URL
  final String apiUrl;

  /// Uploadcare CDN URL
  final String cdnUrl;

  /// Uploadcare authorization scheme [AuthSchemeRegular] or [AuthSchemeSimple]
  final AuthScheme authorizationScheme;

  /// Enable signed uploads mechanism
  final bool useSignedUploads;

  /// Signed upload signature lifetime
  final Duration signedUploadsSignatureLifetime;

  /// Max concurrent request for mulipart uploads
  final int multipartMaxConcurrentChunkRequests;

  /// Max concurrent running isolates. If you are using [ApiUpload.auto] with `runInIsolate` parameter
  final int maxIsolatePoolSize;

  ClientOptions({
    required this.authorizationScheme,
    this.apiUrl = kAPIEndpoint,
    this.cdnUrl = kCDNEndpoint,
    this.uploadUrl = kUploadEndpoint,
    this.useSignedUploads = false,
    this.signedUploadsSignatureLifetime = const Duration(minutes: 30),
    this.multipartMaxConcurrentChunkRequests = 3,
    this.maxIsolatePoolSize = 3,
  }) : assert(
            useSignedUploads ? authorizationScheme.privateKey.isNotEmpty : true,
            'Please provide private key for using signed uploads');
}
