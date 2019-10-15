import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

/// Provides `Uploadcare.Simple` auth scheme
class AuthSchemeSimple extends AuthScheme {
  static const String _name = 'Uploadcare.Simple';

  AuthSchemeSimple({
    @required String publicKey,
    @required String apiVersion,
    String privateKey,
  }) : super(
          apiVersion: apiVersion,
          publicKey: publicKey,
          privateKey: privateKey,
        );

  @protected
  @override
  authorizeRequest(request) {
    request.headers.addAll(Map.fromEntries([
      acceptHeader,
      MapEntry('Authorization', '$_name $publicKey:$privateKey'),
    ]));
  }
}
