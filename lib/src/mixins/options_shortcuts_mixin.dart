import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/options.dart';

mixin UploadcareOptionsShortcutsMixin {
  @protected
  UploadcareOptions get options;

  @protected
  String get publicKey => options.authorizationScheme.publicKey;
  @protected
  String get privateKey => options.authorizationScheme.privateKey;

  @protected
  String get uploadUrl => options.uploadApiUrl;
  @protected
  String get requestUrl => options.requestApiUrl;
  @protected
  String get cdnUrl => options.cdnApiUrl;
}
