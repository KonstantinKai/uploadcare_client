import 'package:meta/meta.dart';
import 'scheme.dart';

/// Provides `Uploadcare.Simple` auth scheme
class AuthSchemeSimple extends AuthScheme {
  static const String _name = 'Uploadcare.Simple';

  AuthSchemeSimple({
    required super.publicKey,
    required super.apiVersion,
    required super.privateKey,
  });

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
