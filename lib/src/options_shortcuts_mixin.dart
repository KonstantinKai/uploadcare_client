import 'package:uploadcare_client/src/options.dart';

mixin UploadcareOptionsShortcutsMixin {
  UploadcareOptions get options;

  String get publicKey => options.authorizationScheme.publicKey;
  String get privateKey => options.authorizationScheme.privateKey;

  String get uploadUrl => options.uploadApiUrl;
  String get requestUrl => options.requestApiUrl;
}
