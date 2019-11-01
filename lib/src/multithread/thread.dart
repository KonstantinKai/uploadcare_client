import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/api_sections/upload.dart';
import 'package:uploadcare_client/src/cancel_token.dart';
import 'package:uploadcare_client/src/entities/progress.dart';
import 'package:uploadcare_client/src/options.dart';

typedef Future<String> UploadInIsolatesCallback(ClientOptions options);

Future<String> uploadInIsolate({
  @required ClientOptions options,
  @required File file,
  bool storeMode,
  ProgressListener onProgress,
  CancelToken cancelToken,
}) async {
  final ReceivePort resultPort = ReceivePort();
  final ReceivePort errorPort = ReceivePort();

  final Isolate isolate = await Isolate.spawn<_UploadConfiguration>(
    _spawn,
    _UploadConfiguration(
      options: options,
      storeMode: storeMode,
      resultPort: resultPort.sendPort,
      file: file,
      cancelToken: cancelToken,
    ),
    errorsAreFatal: true,
    onExit: resultPort.sendPort,
    onError: errorPort.sendPort,
  );
  final Completer<String> result = Completer<String>();
  errorPort.listen((dynamic errorData) {
    assert(errorData is List<dynamic>);
    assert(errorData.length == 2);

    final Exception exception = Exception(errorData[0]);
    final StackTrace stack = StackTrace.fromString(errorData[1]);

    if (result.isCompleted) {
      Zone.current.handleUncaughtError(exception, stack);
    } else {
      result.completeError(exception, stack);
    }
  });

  resultPort.listen((dynamic resultData) {
    if (resultData is ProgressEntity) {
      if (onProgress != null) onProgress(resultData);
    } else if (!result.isCompleted) {
      result.complete(resultData);
    }
  });

  await result.future;

  resultPort.close();
  errorPort.close();
  isolate.kill();

  return result.future;
}

@immutable
class _UploadConfiguration {
  const _UploadConfiguration({
    this.options,
    this.resultPort,
    this.cancelToken,
    this.file,
    this.storeMode,
  });

  final ClientOptions options;
  final SendPort resultPort;
  final File file;
  final bool storeMode;
  final CancelToken cancelToken;
}

Future<void> _spawn(_UploadConfiguration configuration) async {
  final uploader = ApiUpload(options: configuration.options);

  try {
    final result = await uploader.auto(
      configuration.file,
      cancelToken: configuration.cancelToken,
      storeMode: configuration.storeMode,
      onProgress: configuration.resultPort.send,
    );

    configuration.resultPort.send(result);
  } catch (e) {
    configuration.resultPort.send(e);
  }
}
