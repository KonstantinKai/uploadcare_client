import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';
import 'package:mime_type/mime_type.dart';
import 'package:uploadcare_client/src/http.dart';
import 'package:uploadcare_client/src/options.dart';

class UploadcareClient {
  const UploadcareClient({
    @required this.options,
  });

  final UploadcareOptions options;

  String get _publicKey => options.authorizationScheme.publicKey;

  String get _uploadUrl => options.uploadApiUrl;

  Future<String> upload(
    File file, {
    bool storeMode,
    bool forceMultipartUpload = false,
  }) async {
    final filesize = await file.length();

    if (forceMultipartUpload || filesize > options.maxBaseUploadFileSize)
      return _uploadMultipart(
        file,
        storeMode: storeMode,
        filesize: filesize,
      );

    return _uploadBase(
      file,
      storeMode: storeMode,
      filesize: filesize,
    );
  }

  Future<String> _uploadBase(
    File file, {
    bool storeMode,
    int filesize,
  }) async {
    final filename = Uri.parse(file.path).pathSegments.last;
    final params = {
      'UPLOADCARE_PUB_KEY': _publicKey,
      'UPLOADCARE_STORE': storeMode != null ? storeMode ? '1' : '0' : 'auto',
    };

    final client = _createHttpClient('POST', '$_uploadUrl/base/?jsonerrors=1')
      ..fields.addAll(params)
      ..files.add(
        MultipartFile(
          'file',
          file.openRead(),
          filesize,
          filename: filename,
          contentType: MediaType.parse(mime(filename)),
        ),
      );

    final response = await Response.fromStream(await client.send());

    if (response.statusCode == 200) {
      return JsonDecoder().convert(response.body)['file'] as String;
    }

    throw Error();
  }

  Future<String> _uploadMultipart(
    File file, {
    bool storeMode,
    int filesize,
  }) async {
    final filename = Uri.parse(file.path).pathSegments.last;
    final params = {
      'UPLOADCARE_PUB_KEY': _publicKey,
      'UPLOADCARE_STORE': storeMode != null ? storeMode ? '1' : '0' : 'auto',
      'filename': filename,
      'size': filesize.toString(),
      'content_type': mime(filename),
    };

    print(filesize);

    final startClient =
        _createHttpClient('POST', '$_uploadUrl/multipart/start/?jsonerrors=1')
          ..fields.addAll(params);

    final startResponse = await Response.fromStream(await startClient.send());

    if (startResponse.statusCode == 200) {
      final map = JsonDecoder().convert(startResponse.body);
      final urls = (map['parts'] as List).cast<String>();
      final uuid = map['uuid'];
      final int buffer = 5242880;

      final bytes = await file.readAsBytes();

      final responses = await Future.wait(List.generate(urls.length, (index) {
        final url = urls[index];
        final offset = index * buffer;
        final diff = filesize - offset;
        final bytesToRead = buffer < diff ? buffer : diff;

        final chunkClient = _createHttpClient('PUT', url, true)
          ..files.add(
            MultipartFile.fromBytes(
              'file',
              bytes.sublist(offset, offset + bytesToRead),
              contentType: MediaType.parse(mime(filename)),
            ),
          );

        return chunkClient.send().then((value) => Response.fromStream(value));
      }));

      final completeClient = _createHttpClient(
          'POST', '$_uploadUrl/multipart/complete/?jsonerrors=1')
        ..fields.addAll({
          'UPLOADCARE_PUB_KEY': _publicKey,
          'uuid': uuid,
        });

      final completeResponse =
          await Response.fromStream(await completeClient.send());

      if (completeResponse.statusCode == 200) {
        print(JsonDecoder().convert(completeResponse.body));
        return uuid;
      }
    }

    return '';
  }

  UploadcareHttpClient _createHttpClient(String method, String url,
          [bool skipAuth = false]) =>
      UploadcareHttpClient(
        scheme: options.authorizationScheme,
        method: method,
        uri: Uri.parse('$url'),
        skipAuthorization: skipAuth,
      );
}
