import '../../uploadcare_client.dart';
import '../cancel_token.dart';
import '../options.dart';

class IsolateWorker {
  IsolateWorker([this.maxPoolSize = 1]);

  final int maxPoolSize;

  Future<String> upload({
    required ClientOptions options,
    required Object resource,
    bool? storeMode,
    ProgressListener? onProgress,
    CancelToken? cancelToken,
  }) {
    throw UnsupportedError('`dart:isolate` is not supported by this platform');
  }
}
