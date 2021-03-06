import 'package:http/http.dart';

/// To authenticate your account, every request made to https://api.uploadcare.com/ MUST be signed.
/// There are two available auth schemes: a simple one with intuitive auth-param and a more sophisticated and secure one that can be used for Signed Requests.
abstract class AuthScheme {
  /// Uploadcare public key
  final String publicKey;

  /// Uploadcare private key
  final String privateKey;
  final MapEntry<String, String> acceptHeader;
  final String apiVersion;

  AuthScheme({
    required this.publicKey,
    required this.apiVersion,
    this.privateKey = '',
  }) : acceptHeader =
            MapEntry('Accept', 'application/vnd.uploadcare-$apiVersion+json');

  void authorizeRequest(BaseRequest request);
}
