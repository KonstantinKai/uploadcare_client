import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';
import 'package:mime_type/mime_type.dart';
import 'package:uploadcare_client/src/options_shortcuts_mixin.dart';
import 'package:uploadcare_client/src/transport_helper_mixin.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

const int _kChunkSize = 5242880;
const int _kMaxFilesizeForBaseUpload = 10000000;

class UploadcareApiUpload
    with UploadcareOptionsShortcutsMixin, UploadcareTransportHelperMixin {
  UploadcareApiUpload({
    @required this.options,
  }) : assert(options != null);

  final UploadcareOptions options;

  Future<String> auto(
    File file, {
    bool storeMode,
  }) async {
    final filesize = await file.length();

    if (filesize > _kMaxFilesizeForBaseUpload)
      return multipart(
        file,
        storeMode: storeMode,
      );

    return base(
      file,
      storeMode: storeMode,
    );
  }

  Future<String> base(
    File file, {
    bool storeMode,
  }) async {
    final filename = Uri.parse(file.path).pathSegments.last;
    final filesize = await file.length();

    final params = {
      'UPLOADCARE_PUB_KEY': publicKey,
      'UPLOADCARE_STORE': _resolveStoreModeParam(storeMode),
    };

    final client = createMultipartRequest('POST', '$uploadUrl/base/')
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

    return (await resolveStreamedResponse(client.send()))['file'] as String;
  }

  Future<String> multipart(
    File file, {
    bool storeMode,
  }) async {
    final filename = Uri.parse(file.path).pathSegments.last;
    final filesize = await file.length();
    final mimeType = mime(filename);

    if (filesize < _kMaxFilesizeForBaseUpload)
      throw RangeError(
          'Minimum file size to use with Multipart Uploads is 10MB');

    final params = {
      'UPLOADCARE_PUB_KEY': publicKey,
      'UPLOADCARE_STORE': _resolveStoreModeParam(storeMode),
      'filename': filename,
      'size': filesize.toString(),
      'content_type': mimeType,
    };

    final startTransaction =
        createMultipartRequest('POST', '$uploadUrl/multipart/start/')
          ..fields.addAll(params);

    final map = await resolveStreamedResponse(startTransaction.send());
    final urls = (map['parts'] as List).cast<String>();
    final uuid = map['uuid'] as String;

    await Future.wait(List.generate(urls.length, (index) {
      final url = urls[index];
      final offset = index * _kChunkSize;
      final diff = filesize - offset;
      final bytesToRead = _kChunkSize < diff ? _kChunkSize : diff;

      return file
          .openRead(offset, offset + bytesToRead)
          .toList()
          .then((bytesList) => bytesList.expand((list) => list).toList())
          .then((bytes) {
        final chunkTransport = createRequest('PUT', url, false)
          ..bodyBytes = bytes
          ..headers.addAll({
            'Content-Type': mimeType,
          });

        return resolveStreamedResponseStatusCode(chunkTransport.send());
      });
    }));

    final finishTransaction =
        createMultipartRequest('POST', '$uploadUrl/multipart/complete/')
          ..fields.addAll({
            'UPLOADCARE_PUB_KEY': publicKey,
            'uuid': uuid,
          });

    await resolveStreamedResponse(finishTransaction.send());

    return uuid;
  }

  Future<String> fromUrl(
    String url, {
    bool storeMode,
  }) async {
    final request = createRequest(
      'GET',
      '$uploadUrl/from_url/?pub_key=$publicKey&store=${_resolveStoreModeParam(storeMode)}&source_url=$url',
    );
    final map = await resolveStreamedResponse(request.send());

    return '';
  }

  String _resolveStoreModeParam(bool storeMode) =>
      storeMode != null ? storeMode ? '1' : '0' : 'auto';
}
