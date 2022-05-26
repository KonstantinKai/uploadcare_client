import '../api_sections/upload.dart';
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

    /// **Since v0.7**
    Map<String, String>? metadata,
  }) {
    throw UnsupportedError('`dart:isolate` is not supported by this platform');
  }
}
