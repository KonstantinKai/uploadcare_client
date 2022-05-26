import 'package:meta/meta.dart';

/// Provides cancel mechanism to upload process
///
/// Example:
/// ```dart
/// final String cancelMessage = 'some cancel message';
/// final cancelToken = CancelToken(cancelMessage);
/// final future = client.upload.auto(
///   UCFile(File('/some/file')),
///   cancelToken: cancelToken,
/// );
///
/// Future.delayed(const Duration(milliseconds: 500), () => cancelToken.cancel());
///
/// try {
///   await future;
/// } on CancelUploadException catch (e) {
///   // cancelled
/// }
/// ```
class CancelToken {
  CancelToken([this.cancelMessage = '']);

  /// Optional exception message
  final String cancelMessage;

  /// Internal property to handle cancel message **DON'T USE IT IN YOUR CODE**
  @internal
  void Function()? onCancel;

  bool _isCanceled = false;

  /// Indicates cancelled state
  bool get isCanceled => _isCanceled;

  /// Call to cancel upload
  void cancel() {
    if (_isCanceled) {
      return;
    }

    _isCanceled = true;
    if (onCancel != null) {
      onCancel!();
    }
  }
}
