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
  void ensureRightVersion(double expectedVersion, String prefix,
      {bool? exact}) {
    exact ??= false;

    assert(
      exact
          ? options.apiVersion == expectedVersion
          : options.apiVersion >= expectedVersion,
      exact
          ? '$prefix available only for v$expectedVersion version'
          : '$prefix available since v$expectedVersion version',
    );
  }
}
