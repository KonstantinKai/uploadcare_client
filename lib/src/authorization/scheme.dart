import 'package:http/http.dart';
import 'package:meta/meta.dart';

const String _kDefaultApiVersion = 'v0.5';

abstract class AuthScheme {
  AuthScheme({
    @required this.publicKey,
    @required this.privateKey,
    String apiVersion = _kDefaultApiVersion,
  })  : assert(publicKey != null && privateKey != null && apiVersion != null),
        acceptHeader =
            MapEntry('Accept', 'application/vnd.uploadcare-$apiVersion+json');

  final String publicKey;
  final String privateKey;
  final MapEntry<String, String> acceptHeader;

  void authorizeRequest(BaseRequest request);
}
