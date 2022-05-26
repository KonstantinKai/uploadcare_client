class CancelUploadException implements Exception {
  final String message;

  const CancelUploadException([this.message = '']);

  @override
  String toString() {
    if (message.isEmpty) {
      return 'CancelUploadException';
    }

    return 'CancelUploadException: $message';
  }
}
