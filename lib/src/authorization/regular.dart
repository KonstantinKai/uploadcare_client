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
  void injectAuthorizationData(request) {
    final String isoDate = DateTime.now().toUtc().toString();

    request.headers.addAll(Map.fromEntries([
      acceptHeader,
      MapEntry(
        'Date',
        isoDate,
      ),
      MapEntry(
        'Authorization',
        '$_name $publicKey:${_buildSignature(request, isoDate)}',
      ),
    ]));
  }

  String _buildSignature(BaseRequest request, String isoDate) {
    final fields = jsonEncode(request is MultipartRequest
        ? request.fields
        : request is Request ? request.bodyFields : {});

    final String signString = [
      request.method,
      md5.convert(fields.codeUnits).toString(),
      request.headers['Content-Type'],
      isoDate,
      '${request.url.path}?${request.url.query}'
    ].join('\n');

    return Hmac(sha1, privateKey.codeUnits)
        .convert(signString.codeUnits)
        .toString();
  }
}
