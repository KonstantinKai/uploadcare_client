import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

class AuthSchemeSimple extends AuthScheme {
  static const String _name = 'Uploadcare.Simple';

  AuthSchemeSimple({
    @required String publicKey,
    @required String privateKey,
    @required String apiVersion,
  }) : super(
          apiVersion: apiVersion,
          publicKey: publicKey,
          privateKey: privateKey,
        );

  @override
  authorizeRequest(request) {
    request.headers.addAll(Map.fromEntries([
      acceptHeader,
      MapEntry('Authorization', '$_name $publicKey:$privateKey'),
    ]));
  }
}
