import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';
import 'package:mime_type/mime_type.dart';
import 'package:uploadcare_client/src/entities/progress.dart';
import 'package:uploadcare_client/src/entities/url_response.dart';
import 'package:uploadcare_client/src/options_shortcuts_mixin.dart';
import 'package:uploadcare_client/src/transport_helper_mixin.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

const int _kChunkSize = 5242880;
const int _kMaxFilesizeForBaseUpload = 10000000;

typedef void ProgressListener(UploadcareProgress progress);

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

    final client =
        createMultipartRequest('POST', buildUri('$uploadUrl/base/'), false)
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
    int maxConcurrentChunkRequests = 3,
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

    final startTransaction = createMultipartRequest(
        'POST', buildUri('$uploadUrl/multipart/start/'), false)
      ..fields.addAll(params);

    final map = await resolveStreamedResponse(startTransaction.send());
    final urls = (map['parts'] as List).cast<String>();
    final uuid = map['uuid'] as String;

    final readyRequests = await Future.wait(List.generate(urls.length, (index) {
      final url = urls[index];
      final offset = index * _kChunkSize;
      final diff = filesize - offset;
      final bytesToRead = _kChunkSize < diff ? _kChunkSize : diff;

      return file
          .openRead(offset, offset + bytesToRead)
          .toList()
          .then((bytesList) => bytesList.expand((list) => list).toList())
          .then((bytes) => createRequest('PUT', buildUri(url), false)
            ..bodyBytes = bytes
            ..headers.addAll({
              'Content-Type': mimeType,
            }));
    }));

    await Future.wait(List.generate(maxConcurrentChunkRequests, (index) {
      final int maxInchunk = (urls.length / maxConcurrentChunkRequests).ceil();
      final start = index * maxInchunk;
      int end = start + maxInchunk;

      if (index == maxConcurrentChunkRequests - 1) end -= end - urls.length;

      return readyRequests.sublist(start, end).fold(
          Future.value(),
          (prev, next) => prev.then((_) {
                print('run -> ${next.url.queryParameters['partNumber']}');
                return resolveStreamedResponseStatusCode(next.send());
              }));
    }));

    // await Future.wait(List.generate(urls.length, (index) {
    //   final url = urls[index];
    //   final offset = index * _kChunkSize;
    //   final diff = filesize - offset;
    //   final bytesToRead = _kChunkSize < diff ? _kChunkSize : diff;

    //   return file
    //       .openRead(offset, offset + bytesToRead)
    //       .toList()
    //       .then((bytesList) => bytesList.expand((list) => list).toList())
    //       .then((bytes) {
    //     final chunkTransport = createRequest('PUT', buildUri(url), false)
    //       ..bodyBytes = bytes
    //       ..headers.addAll({
    //         'Content-Type': mimeType,
    //       });

    //     return resolveStreamedResponseStatusCode(chunkTransport.send());
    //   });
    // }));

    final finishTransaction = createMultipartRequest(
        'POST', buildUri('$uploadUrl/multipart/complete/'), false)
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
    ProgressListener onProgress,
    Duration checkInterval = const Duration(seconds: 1),
  }) async {
    final request = createMultipartRequest(
      'POST',
      buildUri('$uploadUrl/from_url/'),
      false,
    )..fields.addAll({
        'pub_key': publicKey,
        'store': _resolveStoreModeParam(storeMode),
        'source_url': url,
      });

    final token =
        (await resolveStreamedResponse(request.send()))['token'] as String;

    String fileId;

    await for (UrlUploadStatusResponse response
        in _uploadStatusStream(token, checkInterval)) {
      if (response.status == UrlUploadStatus.Error)
        throw ClientException(response.errorMessage);

      if (response.status == UrlUploadStatus.Success)
        fileId = response.fileInfo.id;

      if (response.progress != null && onProgress != null)
        onProgress(response.progress);
    }

    return fileId;
  }

  Stream<UrlUploadStatusResponse> _uploadStatusStream(
    String token,
    Duration checkInterval,
  ) async* {
    while (true) {
      sleep(checkInterval);
      final response = UrlUploadStatusResponse.fromJson(
        await resolveStreamedResponse(
          createRequest(
            'GET',
            buildUri(
              '$uploadUrl/from_url/status/',
              {
                'token': token,
              },
            ),
            false,
          ).send(),
        ),
      );

      yield response;

      if (response.status != UrlUploadStatus.Progress) break;
    }
  }

  String _resolveStoreModeParam(bool storeMode) =>
      storeMode != null ? storeMode ? '1' : '0' : 'auto';
}

typedef Future ConcurrentAction();

class ConcurrentRunner<T> {
  ConcurrentRunner(
    this.limit,
  ) : _pendings = Set();

  final int limit;
  final Set<Future> _pendings;

  run(List<ConcurrentAction> actions) async {
    while (_pendings.length < limit) {
      final f = actions.removeLast()();
      _pendings.add(f.then((_) => _pendings.remove(f)));
    }

    Future.any(_pendings).then((_) => run(actions));
  }
}
