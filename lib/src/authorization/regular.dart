import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/authorization/scheme.dart';

class UploadcareAuthSchemeRegular extends UploadcareAuthScheme {
  static const String _name = 'Uploadcare';

  UploadcareAuthSchemeRegular({
    @required String publicKey,
    @required String privateKey,
    @required String apiVersion,
  }) : super(
          apiVersion: apiVersion,
          publicKey: publicKey,
          privateKey: privateKey,
        );

  @override
  void injectAuthorizationData(MultipartRequest request) {
    final String isoDate = DateTime.now().toUtc().toString();

    request.headers.addAll(Map.fromEntries([
      MapEntry('Content-Type', 'application/json'),
      acceptHeader,
      MapEntry('Date', isoDate),
      MapEntry('Authorization',
          '$_name $publicKey:${_buildSignature(request, isoDate)}'),
    ]));
  }

  String _buildSignature(MultipartRequest request, String isoDate) {
    final String signString = [
      request.method,
      md5.convert(JsonCodec().encode(request.fields).codeUnits).toString(),
      'application/json',
      isoDate,
      '${request.url.path}?${request.url.query}'
    ].join('\n');

    return Hmac(sha1, privateKey.codeUnits)
        .convert(signString.codeUnits)
        .toString();
  }
}
