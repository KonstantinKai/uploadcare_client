import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'scheme.dart';

const List<String> _kMonthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _kDayNames = [
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat'
];

/// Provides `Uploadcare` (regular) auth scheme
class AuthSchemeRegular extends AuthScheme {
  static const String _name = 'Uploadcare';

  AuthSchemeRegular({
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
  void authorizeRequest(request) {
    final String isoDate = _formatToRFC822Date(DateTime.now());

    request.headers.addAll(Map.fromEntries([
      acceptHeader,
      MapEntry(
        HttpHeaders.dateHeader,
        isoDate,
      ),
      MapEntry(
        HttpHeaders.authorizationHeader,
        '$_name $publicKey:${_buildSignature(request, isoDate)}',
      ),
    ]));
  }

  String _formatToRFC822Date(DateTime now) {
    final date = now.toUtc();
    final dayName = _kDayNames[date.weekday - 1];
    final monthName = _kMonthNames[date.month - 1];

    return '$dayName, ${date.day} $monthName ${date.year} ${date.hour}:${date.minute}:${date.second} GMT';
  }

  String _buildSignature(BaseRequest request, String isoDate) {
    final fields = request is MultipartRequest
        ? jsonEncode(request.fields)
        : request is Request ? request.body : '';

    final String signString = [
      request.method,
      md5.convert(fields.codeUnits).toString(),
      request.headers[HttpHeaders.contentTypeHeader],
      isoDate,
      request.url.path +
          (request.url.query.isNotEmpty ? '?${request.url.query}' : ''),
    ].join('\n');

    return Hmac(sha1, privateKey.codeUnits)
        .convert(signString.codeUnits)
        .toString();
  }
}
