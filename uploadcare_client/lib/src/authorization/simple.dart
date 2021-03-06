import 'package:meta/meta.dart';
import 'scheme.dart';

/// Provides `Uploadcare.Simple` auth scheme
class AuthSchemeSimple extends AuthScheme {
  static const String _name = 'Uploadcare.Simple';

  AuthSchemeSimple({
    required String publicKey,
    required String apiVersion,
    required privateKey,
  }) : super(
          apiVersion: apiVersion,
          publicKey: publicKey,
          privateKey: privateKey,
        );

  @protected
  @override
  void authorizeRequest(request) {
    request.headers.addAll(Map.fromEntries([
      acceptHeader,
      MapEntry(
        'authorization',
        '$_name $publicKey:$privateKey',
      ),
    ]));
  }
}
