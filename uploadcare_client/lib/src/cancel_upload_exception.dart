class CancelUploadException implements Exception {
  final String message;

  const CancelUploadException([this.message = '']);

  @override
  String toString() {
    if (message.isNotEmpty) {
      return 'CancelUploadException';
    }

    return 'CancelUploadException: $message';
  }
}
