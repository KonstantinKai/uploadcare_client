import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/api_sections/upload.dart';
import 'package:uploadcare_client/src/cancel_token.dart';
import 'package:uploadcare_client/src/concurrent_runner.dart';
import 'package:uploadcare_client/src/entities/progress.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

class IsolateWorker {
  static IsolateWorker _instance;

  IsolateWorker._(this.maxPoolSize) : assert(maxPoolSize > 0);

  factory IsolateWorker([int maxPoolSize = 1]) =>
      _instance ??= IsolateWorker._(maxPoolSize);

  final int maxPoolSize;
  final Queue<ConcurrentAction> _scheduled = Queue();

  int _inProgress = 0;

  Future<String> upload({
    @required ClientOptions options,
    @required dynamic resource,
    bool storeMode,
    ProgressListener onProgress,
    CancelToken cancelToken,
  }) {
    final Completer<String> completer = Completer();

    final action = () => _uploadInIsolate(
          options: options,
          resource: resource,
          storeMode: storeMode,
          onProgress: onProgress,
          cancelToken: cancelToken,
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
    @required ClientOptions options,
    @required dynamic resource,
    bool storeMode,
    ProgressListener onProgress,
    CancelToken cancelToken,
  }) async {
    final ReceivePort resultPort = ReceivePort();
    final ReceivePort errorPort = ReceivePort();

    final Isolate isolate = await Isolate.spawn<_UploadConfiguration>(
      _upload,
      _UploadConfiguration(
        options: options,
        storeMode: storeMode,
        resultSendPort: resultPort.sendPort,
        cancellable: cancelToken != null,
        resource: resource,
      ),
      errorsAreFatal: true,
      onExit: resultPort.sendPort,
      onError: errorPort.sendPort,
    );

    final Completer<String> result = Completer<String>();

    errorPort.listen((dynamic errorData) {
      assert(errorData is List<dynamic>);
      assert(errorData.length == 2);

      final Exception exception = errorData[0] == 'CancelUploadException'
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
            (cancelToken != null ? !cancelToken.isCanceled : true))
          onProgress(message);
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
    this.options,
    this.resultSendPort,
    this.resource,
    this.storeMode,
    this.cancellable,
  });

  final ClientOptions options;
  final SendPort resultSendPort;
  final dynamic resource;
  final bool storeMode;
  final bool cancellable;
}

Future<void> _upload(_UploadConfiguration configuration) async {
  final uploader = ApiUpload(options: configuration.options);

  CancelToken cancelToken;
  ReceivePort cancelRecievePort;

  if (configuration.cancellable) {
    cancelToken = CancelToken();
    cancelRecievePort = ReceivePort()
      ..listen((message) {
        if (message is CancelUploadException) cancelToken.cancel();
      });
    configuration.resultSendPort.send(cancelRecievePort.sendPort);
  }

  try {
    final result = await uploader.auto(
      configuration.resource,
      storeMode: configuration.storeMode,
      onProgress: configuration.resultSendPort.send,
      cancelToken: cancelToken,
    );

    cancelRecievePort?.close();
    configuration.resultSendPort.send(result);
  } catch (e) {
    cancelRecievePort?.close();
    rethrow;
  }
}
