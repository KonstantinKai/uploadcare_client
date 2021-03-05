class CancelUploadException implements Exception {
  final String? message;

  const CancelUploadException([this.message]);

  @override
  String toString() {
    if (message == null) return 'CancelUploadException';
    return 'CancelUploadException: $message';
  }
}
