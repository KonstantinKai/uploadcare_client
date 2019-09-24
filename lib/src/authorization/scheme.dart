import 'package:http/http.dart';
import 'package:meta/meta.dart';

abstract class AuthScheme {
  AuthScheme({
    @required this.publicKey,
    @required this.privateKey,
    @required String apiVersion,
  })  : assert(publicKey != null && privateKey != null && apiVersion != null),
        acceptHeader =
            MapEntry('Accept', 'application/vnd.uploadcare-$apiVersion+json');

  final String publicKey;
  final String privateKey;
  final MapEntry<String, String> acceptHeader;

  void authorizeRequest(BaseRequest request);
}
