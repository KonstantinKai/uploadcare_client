import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

import 'package:meta/meta.dart';

import '../api_sections/upload.dart';
import '../cancel_token.dart';
import '../cancel_upload_exception.dart';
import '../concurrent_runner.dart';
import '../options.dart';
import '../entities/progress.dart';

@internal
class IsolateWorker {
  static IsolateWorker? _instance;

  IsolateWorker._(this.maxPoolSize) : assert(maxPoolSize > 0);

  factory IsolateWorker([int maxPoolSize = 1]) =>
      _instance ??= IsolateWorker._(maxPoolSize);

  final int maxPoolSize;
  final _scheduled = Queue<ConcurrentAction>();

  int _inProgress = 0;

  Future<String> upload({
    required ClientOptions options,
    required Object resource,
    bool? storeMode,
    ProgressListener? onProgress,
    CancelToken? cancelToken,
    String? overrideFilename,
    int? maxRetries,

    /// **Since v0.7**
    Map<String, String>? metadata,
  }) {
    final completer = Completer<String>();

    // ignore: prefer_function_declarations_over_variables
    final action = () => _uploadInIsolate(
          options: options,
          resource: resource,
          storeMode: storeMode,
          onProgress: onProgress,
          cancelToken: cancelToken,
          overrideFilename: overrideFilename,
          maxRetries: maxRetries,
          metadata: metadata,
        ).then((id) {
          if (!completer.isCompleted) completer.complete(id);
        }).catchError((error) {
          if (!completer.isCompleted) completer.completeError(error);
        });

    if (_inProgress < maxPoolSize) {
      _inProgress++;
      action();
    } else {
      _scheduled.add(action);
    }

    return completer.future.whenComplete(() {
      _inProgress--;

      if (_scheduled.isNotEmpty) {
        _scheduled.removeFirst()();
      }
    });
  }

  Future<String> _uploadInIsolate({
    required ClientOptions options,
    required Object resource,
    bool? storeMode,
    ProgressListener? onProgress,
    CancelToken? cancelToken,
    String? overrideFilename,
    int? maxRetries,

    /// **Since v0.7**
    Map<String, String>? metadata,
  }) async {
    final resultPort = ReceivePort();
    final errorPort = ReceivePort();
    final cancellable = cancelToken != null;

    final Isolate isolate = await Isolate.spawn<_UploadConfiguration>(
      _upload,
      _UploadConfiguration(
        options: options,
        resultSendPort: resultPort.sendPort,
        cancellable: cancellable,
        resource: resource,
        storeMode: storeMode,
        overrideFilename: overrideFilename,
        maxRetries: maxRetries,
        metadata: metadata,
      ),
      errorsAreFatal: true,
      onExit: resultPort.sendPort,
      onError: errorPort.sendPort,
    );

    final result = Completer<String>();

    errorPort.listen((dynamic errorData) {
      assert(errorData is List<dynamic>);
      assert(errorData.length == 2);

      final Exception exception =
          errorData[0] == 'CancelUploadException' && cancellable
              ? CancelUploadException(cancelToken.cancelMessage)
              : Exception(errorData[0]);
      final StackTrace stack = StackTrace.fromString(errorData[1]);

      if (result.isCompleted) {
        Zone.current.handleUncaughtError(exception, stack);
      } else {
        result.completeError(exception, stack);
      }
    });

    resultPort.listen((dynamic message) {
      if (message is ProgressEntity) {
        if (onProgress != null &&
            (cancelToken != null ? !cancelToken.isCanceled : true)) {
          onProgress(message);
        }
      } else if (message is SendPort) {
        if (cancelToken != null) {
          cancelToken.onCancel = () => message.send(CancelUploadException());
        }
      } else if (!result.isCompleted) {
        result.complete(message);
      }
    });

    await result.future;

    resultPort.close();
    errorPort.close();
    isolate.kill();

    return result.future;
  }
}

class _UploadConfiguration {
  const _UploadConfiguration({
    required this.options,
    required this.resultSendPort,
    required this.resource,
    required this.cancellable,
    this.storeMode,
    this.overrideFilename,
    this.maxRetries,
    this.metadata,
  });

  final ClientOptions options;
  final SendPort resultSendPort;
  final Object resource;
  final bool cancellable;
  final bool? storeMode;
  final String? overrideFilename;
  final int? maxRetries;
  final Map<String, String>? metadata;
}

Future<void> _upload(_UploadConfiguration configuration) async {
  final uploader = ApiUpload(options: configuration.options);

  CancelToken? cancelToken;
  ReceivePort? cancelRecievePort;

  if (configuration.cancellable) {
    cancelToken = CancelToken();
    cancelRecievePort = ReceivePort()
      ..listen((message) {
        if (message is CancelUploadException) cancelToken!.cancel();
      });
    configuration.resultSendPort.send(cancelRecievePort.sendPort);
  }

  try {
    final result = await uploader.auto(
      configuration.resource,
      storeMode: configuration.storeMode,
      onProgress: configuration.resultSendPort.send,
      cancelToken: cancelToken,
      overrideFilename: configuration.overrideFilename,
      maxRetries: configuration.maxRetries,
      metadata: configuration.metadata,
    );

    cancelRecievePort?.close();
    configuration.resultSendPort.send(result);
  } catch (e) {
    cancelRecievePort?.close();
    rethrow;
  }
}
