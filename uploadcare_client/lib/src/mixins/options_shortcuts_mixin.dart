import 'package:meta/meta.dart';
import '../options.dart';

@internal
mixin OptionsShortcutMixin {
  @protected
  ClientOptions get options;

  @protected
  String get publicKey => options.authorizationScheme.publicKey;
  @protected
  String? get privateKey => options.authorizationScheme.privateKey;

  @protected
  String get uploadUrl => options.uploadUrl;
  @protected
  String get apiUrl => options.apiUrl;
  @protected
  String get cdnUrl => options.cdnUrl;

  @protected
  void ensureRightVersion(double since, String prefix) {
    assert(
      options.apiVersion >= since,
      '$prefix available since v$since version',
    );
  }
}
