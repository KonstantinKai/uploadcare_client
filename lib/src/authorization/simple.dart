import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

class UploadcareAuthSchemeSimple extends UploadcareAuthScheme {
  static const String _name = 'Uploadcare.Simple';

  UploadcareAuthSchemeSimple({
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
