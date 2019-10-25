class CancelUploadException implements Exception {
  final String message;

  const CancelUploadException([this.message]);

  String toString() {
    if (message == null) return 'CancelUploadException';
    return 'CancelUploadException: $message';
  }
}
