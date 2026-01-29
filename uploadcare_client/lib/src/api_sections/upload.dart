import 'dart:async';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mime/mime.dart';

import '../cancel_token.dart';
import '../cancel_upload_exception.dart';
import '../concurrent_runner.dart';
import '../entities/entities.dart';
import '../file/uc_file.dart';
import '../mixins/mixins.dart';
import '../options.dart';
import '../transport.dart';
import '../isolate/isolate_worker_stub.dart'
    if (dart.library.io) '../isolate/isolate_worker.dart';

const int _kChunkSize = 5242880;
const int _kRecomendedMaxFilesizeForBaseUpload = 10000000;
const int _kDefaultMaxRetries = 3;
const Duration _kInitialRetryDelay = Duration(seconds: 1);

typedef ProgressListener = void Function(ProgressEntity progress);

/// Provides API for uploading files
///
/// ```dart
/// final upload = ApiUpload(options: options);
/// ...
/// final file1 = UCFile(File('/some/file'));
/// final file2 = 'https://some/file';
///
/// final id1 = await upload.auto(file1); // File instance
/// final id2 = await upload.auto(file2); // URL to file
/// final id3 = await upload.auto(file1.path) // path to file;
/// ```
///
/// Run upload process in isolate
/// ```dart
/// final upload = ApiUpload(options: options);
/// ...
/// final id = await upload.auto(UCFile(File('/some/file')), runInIsolate: true);
/// ```
class ApiUpload with OptionsShortcutMixin, TransportHelperMixin {
  @override
  final ClientOptions options;

  ApiUpload({
    required this.options,
  });

  /// Upload file [resource] according to type
  /// if `String` makes [fromUrl] upload if it is http/https url or try retrieve [UCFile] if path is absolute, otherwise make an `UCFile` request according to size
  Future<String> auto(
    Object resource, {
    bool runInIsolate = false,
    bool? storeMode,
    ProgressListener? onProgress,
    CancelToken? cancelToken,
    String? overrideFilename,
    int? maxRetries,

    /// **Since v0.7**
    Map<String, String>? metadata,
  }) async {
    assert(resource is String || resource is UCFile,
        'The resource should be one of `UCFile` or `URL` and `File` path');

    if (runInIsolate) {
      return _runInIsolate(
        resource,
        storeMode: storeMode,
        onProgress: onProgress,
        cancelToken: cancelToken,
        overrideFilename: overrideFilename,
        maxRetries: maxRetries,
        metadata: metadata,
      );
    }

    if (resource is String && resource.isNotEmpty) {
      Uri? uri = Uri.tryParse(resource);

      if (uri != null) {
        if (['http', 'https'].contains(uri.scheme)) {
          return fromUrl(
            resource,
            storeMode: storeMode,
            onProgress: onProgress,
            metadata: metadata,
          );
        } else if (uri.hasAbsolutePath) {
          resource = UCFile.fromUri(uri);
        } else {
          throw ArgumentError('Cannot parse URL from string');
        }
      }
    }

    if (resource is UCFile) {
      final file = resource;
      final filesize = await file.length();

      if (filesize > _kRecomendedMaxFilesizeForBaseUpload) {
        return multipart(
          file,
          storeMode: storeMode,
          onProgress: onProgress,
          cancelToken: cancelToken,
          metadata: metadata,
          overrideFilename: overrideFilename,
          maxRetries: maxRetries,
        );
      }

      return base(
        file,
        storeMode: storeMode,
        onProgress: onProgress,
        cancelToken: cancelToken,
        metadata: metadata,
        overrideFilename: overrideFilename,
        maxRetries: maxRetries,
      );
    }

    throw ArgumentError('Make sure you passed File or URL string');
  }

  /// Make upload to `/base` endpoint
  ///
  /// [storeMode]`=null` - auto store
  /// [storeMode]`=true` - store file
  /// [storeMode]`=false` - keep file for 24h in storage
  /// [onProgress] subscribe to progress event
  /// [cancelToken] make cancelable request
  /// [maxRetries] maximum retry attempts for failed uploads (default: 3)
  Future<String> base(
    UCFile file, {
    bool? storeMode,
    ProgressListener? onProgress,
    CancelToken? cancelToken,
    String? overrideFilename,
    int? maxRetries,

    /// **Since v0.7**
    Map<String, String>? metadata,
  }) async {
    _ensureRightVersionForMetadata(metadata);

    maxRetries ??= _kDefaultMaxRetries;

    final filename = overrideFilename ?? file.name;
    final filesize = await file.length();
    final mimeType = file.mimeType.isNotEmpty
        ? file.mimeType
        : (lookupMimeType(filename.toLowerCase()) ?? '');

    metadata ??= {};

    Exception? lastException;
    UcMultipartRequest? currentRequest;

    if (cancelToken != null) {
      cancelToken.onCancel = () {
        currentRequest?.cancel();
      };
    }

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      if (cancelToken != null && cancelToken.isCanceled) {
        throw CancelUploadException(cancelToken.cancelMessage);
      }

      ProgressEntity progress = ProgressEntity(0, filesize);

      final client =
          createMultipartRequest('POST', buildUri('$uploadUrl/base/'), false)
            ..fields.addAll({
              'UPLOADCARE_PUB_KEY': publicKey,
              'UPLOADCARE_STORE': resolveStoreModeParam(storeMode),
              if (options.useSignedUploads) ..._signUpload(),
              for (MapEntry entry in metadata.entries)
                'metadata[${entry.key}]': entry.value,
            })
            ..files.add(
              MultipartFile(
                'file',
                file.openRead().transform(
                      StreamTransformer.fromHandlers(
                        handleData: (data, sink) {
                          final next = progress.copyWith(
                              uploaded: progress.uploaded + data.length);
                          final shouldCall = next.value > progress.value;
                          progress = next;

                          if (onProgress != null && shouldCall) {
                            onProgress(progress);
                          }
                          sink.add(data);
                        },
                        handleDone: (sink) => sink.close(),
                      ),
                    ),
                filesize,
                filename: filename,
                contentType: MediaType.parse(mimeType),
              ),
            );

      currentRequest = client;

      try {
        final data = await resolveStreamedResponse(client.send());
        return data['file'] as String;
      } on ClientException catch (e) {
        if (cancelToken != null && cancelToken.isCanceled) {
          throw CancelUploadException(cancelToken.cancelMessage);
        }
        lastException = e;
        if (attempt < maxRetries - 1) {
          // Exponential backoff: 1s, 2s, 4s, ...
          await Future.delayed(_kInitialRetryDelay * (1 << attempt));
        }
      }
    }

    throw lastException ?? ClientException('Upload failed after $maxRetries attempts');
  }

  /// Make upload to `/multipart` endpoint
  /// [maxConcurrentChunkRequests] maximum concurrent requests
  /// [cancelToken] make cancelable request
  /// [maxRetries] maximum retry attempts for failed chunk uploads (default: 3)
  Future<String> multipart(
    UCFile file, {
    bool? storeMode,
    ProgressListener? onProgress,
    CancelToken? cancelToken,
    int? maxConcurrentChunkRequests,
    String? overrideFilename,
    int? maxRetries,

    /// **Since v0.7**
    Map<String, String>? metadata,
  }) async {
    _ensureRightVersionForMetadata(metadata);

    maxConcurrentChunkRequests ??= options.multipartMaxConcurrentChunkRequests;
    maxRetries ??= _kDefaultMaxRetries;
    metadata ??= {};

    final filename = overrideFilename ?? file.name;
    final filesize = await file.length();
    final mimeType = file.mimeType.isNotEmpty
        ? file.mimeType
        : (lookupMimeType(filename.toLowerCase()) ?? '');

    assert(filesize > _kRecomendedMaxFilesizeForBaseUpload,
        'Minimum file size to use with Multipart Uploads is 10MB');

    final completer = Completer<String>();

    final startTransaction = createMultipartRequest(
        'POST', buildUri('$uploadUrl/multipart/start/'), false)
      ..fields.addAll({
        'UPLOADCARE_PUB_KEY': publicKey,
        'UPLOADCARE_STORE': resolveStoreModeParam(storeMode),
        'filename': filename,
        'size': filesize.toString(),
        'content_type': mimeType,
        if (options.useSignedUploads) ..._signUpload(),
        for (MapEntry entry in metadata.entries)
          'metadata[${entry.key}]': entry.value,
      });

    if (cancelToken != null) {
      cancelToken.onCancel = _completeWithError(
        completer: completer,
        action: () => startTransaction.cancel(),
        cancelMessage: cancelToken.cancelMessage,
      );
    }

    // ignore: unawaited_futures
    resolveStreamedResponse(startTransaction.send()).then((map) async {
      final urls = (map['parts'] as List).cast<String>();
      final uuid = map['uuid'] as String;
      final inProgressRequests = <UcRequest>[];

      ProgressEntity progress = ProgressEntity(0, filesize);

      if (onProgress != null) onProgress(progress);

      final actions = urls.asMap().entries.map((entry) {
        final index = entry.key;
        final url = entry.value;
        final offset = index * _kChunkSize;
        final bytesToRead = min(_kChunkSize, filesize - offset);

        return () => _uploadChunkWithRetry(
              file: file,
              url: url,
              offset: offset,
              bytesToRead: bytesToRead,
              mimeType: mimeType,
              cancelToken: cancelToken,
              maxRetries: maxRetries!,
              inProgressRequests: inProgressRequests,
              onChunkComplete: () {
                if (onProgress != null) {
                  onProgress(progress = progress.copyWith(
                    uploaded: progress.uploaded + bytesToRead,
                  ));
                }
              },
            );
      }).toList();

      if (cancelToken != null) {
        cancelToken.onCancel = _completeWithError(
          completer: completer,
          action: () {
            for (var request in inProgressRequests) {
              request.cancel();
            }
          },
          cancelMessage: cancelToken.cancelMessage,
        );
      }

      await ConcurrentRunner<Response?>(maxConcurrentChunkRequests!, actions)
          .run();

      final finishTransaction = createMultipartRequest(
          'POST', buildUri('$uploadUrl/multipart/complete/'), false)
        ..fields.addAll({
          'UPLOADCARE_PUB_KEY': publicKey,
          'uuid': uuid,
          if (options.useSignedUploads) ..._signUpload(),
        });

      if (!completer.isCompleted) {
        completer.complete(
          resolveStreamedResponse(finishTransaction.send()).then((_) => uuid),
        );
      }
    }).catchError((e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Collects bytes from a stream into a single [Uint8List] efficiently.
  /// Avoids multiple allocations by pre-calculating total size.
  Future<Uint8List> _collectBytes(
    Stream<List<int>> stream,
    int expectedSize,
  ) async {
    final bytes = Uint8List(expectedSize);
    var offset = 0;
    await for (final chunk in stream) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return bytes;
  }

  /// Uploads a single chunk to the specified URL.
  Future<Response> _uploadChunk({
    required UCFile file,
    required String url,
    required int offset,
    required int bytesToRead,
    required String mimeType,
    required CancelToken? cancelToken,
    required List<UcRequest> inProgressRequests,
    required void Function() onChunkComplete,
  }) async {
    if (cancelToken != null && cancelToken.isCanceled) {
      throw CancelUploadException(cancelToken.cancelMessage);
    }

    final bytes = await _collectBytes(
      file.openRead(offset, offset + bytesToRead),
      bytesToRead,
    );

    final request = createRequest('PUT', buildUri(url), false)
      ..bodyBytes = bytes
      ..headers.addAll({'Content-Type': mimeType});

    inProgressRequests.add(request);

    try {
      final response = await resolveStreamedResponseStatusCode(request.send());
      onChunkComplete();
      return response;
    } finally {
      inProgressRequests.remove(request);
    }
  }

  /// Uploads a chunk with retry logic and exponential backoff.
  Future<Response?> _uploadChunkWithRetry({
    required UCFile file,
    required String url,
    required int offset,
    required int bytesToRead,
    required String mimeType,
    required CancelToken? cancelToken,
    required int maxRetries,
    required List<UcRequest> inProgressRequests,
    required void Function() onChunkComplete,
  }) async {
    if (cancelToken != null && cancelToken.isCanceled) {
      return null;
    }

    Exception? lastException;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await _uploadChunk(
          file: file,
          url: url,
          offset: offset,
          bytesToRead: bytesToRead,
          mimeType: mimeType,
          cancelToken: cancelToken,
          inProgressRequests: inProgressRequests,
          onChunkComplete: onChunkComplete,
        );
      } on CancelUploadException {
        return null;
      } on ClientException catch (e) {
        lastException = e;
        if (attempt < maxRetries - 1) {
          // Exponential backoff: 1s, 2s, 4s, ...
          await Future.delayed(_kInitialRetryDelay * (1 << attempt));
        }
      }
    }

    throw lastException ?? ClientException('Chunk upload failed after $maxRetries attempts');
  }

  /// Make upload to `/fromUrl` endpoint
  Future<String> fromUrl(
    String url, {
    Duration checkInterval = const Duration(seconds: 1),
    bool? storeMode,
    ProgressListener? onProgress,

    /// **Since v0.7**
    Map<String, String>? metadata,

    /// If set to `true`, enables the [url] duplicates prevention.
    /// Specifically, if the [url] had already been fetched and uploaded previously, this request will return information about the already uploaded file.
    bool? checkURLDuplicates,

    /// Determines if the requested [url] should be kept in the history of fetched/uploaded URLs.
    /// If the value is not defined explicitly, it is set to the value of the [checkURLDuplicates] parameter.
    bool? saveURLDuplicates,
  }) async {
    _ensureRightVersionForMetadata(metadata);

    metadata ??= {};

    final request = createMultipartRequest(
      'POST',
      buildUri('$uploadUrl/from_url/'),
      false,
    )..fields.addAll({
        'pub_key': publicKey,
        'store': resolveStoreModeParam(storeMode),
        'source_url': url,
        if (checkURLDuplicates != null)
          'check_URL_duplicates': resolveStoreModeParam(checkURLDuplicates),
        if (saveURLDuplicates != null)
          'save_URL_duplicates': resolveStoreModeParam(saveURLDuplicates),
        if (options.useSignedUploads) ..._signUpload(),
        for (MapEntry entry in metadata.entries)
          'metadata[${entry.key}]': entry.value,
      });

    final result = await resolveStreamedResponse(request.send());

    if (result['uuid'] != null) {
      return result['uuid'] as String;
    }

    final token = result['token'] as String;

    await for (UrlUploadStatusEntity response
        in _urlUploadStatusAsStream(token, checkInterval)) {
      if (response.status == UrlUploadStatusValue.Error) {
        throw ClientException(response.errorMessage);
      }

      if (response.status == UrlUploadStatusValue.Success) {
        return response.fileInfo!.id;
      }

      if (response.progress != null && onProgress != null) {
        onProgress(response.progress!);
      }
    }

    throw ClientException('Unsupported response received');
  }

  Future<void> _statusTimerCallback(
    String token,
    Duration checkInterval,
    StreamController<UrlUploadStatusEntity> controller,
  ) async {
    final response = UrlUploadStatusEntity.fromJson(
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

    controller.add(response);

    if ([UrlUploadStatusValue.Progress, UrlUploadStatusValue.Waiting]
        .contains(response.status)) {
      Timer(
        checkInterval,
        () => _statusTimerCallback(token, checkInterval, controller),
      );
      return;
    }

    // ignore: unawaited_futures
    controller.close();
  }

  Stream<UrlUploadStatusEntity> _urlUploadStatusAsStream(
    String token,
    Duration checkInterval,
  ) {
    final StreamController<UrlUploadStatusEntity> controller =
        StreamController.broadcast();

    Timer(
      checkInterval,
      () => _statusTimerCallback(token, checkInterval, controller),
    );

    return controller.stream;
  }

  Map<String, String> _signUpload() {
    final expire = DateTime.now()
            .add(options.signedUploadsSignatureLifetime)
            .millisecondsSinceEpoch ~/
        1000;

    final signature = md5.convert('$privateKey$expire'.codeUnits).toString();

    return {
      'signature': signature,
      'expire': expire.toString(),
    };
  }

  void Function() _completeWithError({
    required Completer<String> completer,
    required void Function() action,
    String cancelMessage = '',
  }) =>
      () {
        if (!completer.isCompleted) {
          action();
          completer.completeError(CancelUploadException(cancelMessage));
        }
      };

  Future<String> _runInIsolate(
    Object resource, {
    bool? storeMode,
    ProgressListener? onProgress,
    CancelToken? cancelToken,
    String? overrideFilename,
    int? maxRetries,

    /// **Since v0.7**
    Map<String, String>? metadata,
  }) {
    _ensureRightVersionForMetadata(metadata);

    final poolSize = options.maxIsolatePoolSize;
    final isolateWorker = IsolateWorker(poolSize);

    return isolateWorker.upload(
      options: options,
      resource: resource,
      storeMode: storeMode,
      onProgress: onProgress,
      cancelToken: cancelToken,
      overrideFilename: overrideFilename,
      maxRetries: maxRetries,
      metadata: metadata,
    );
  }

  void _ensureRightVersionForMetadata(Map<String, String>? metadata) {
    if (metadata == null) return;

    ensureRightVersion(0.7, 'Save metadata');
  }
}
