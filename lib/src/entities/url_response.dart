import 'package:uploadcare_client/src/entities/file_info.dart';
import 'package:uploadcare_client/src/entities/progress.dart';

enum UrlUploadStatus {
  Progress,
  Error,
  Success,
}

class UrlUploadStatusResponse {
  final UrlUploadStatus status;
  final String errorMessage;
  final UploadcareFileInfo fileInfo;
  final UploadcareProgress progress;

  const UrlUploadStatusResponse({
    this.status,
    this.errorMessage,
    this.fileInfo,
    this.progress,
  });

  factory UrlUploadStatusResponse.fromJson(Map<String, dynamic> json) {
    final stringStatus = json['status'];
    UrlUploadStatus status;

    if (stringStatus == 'progress') status = UrlUploadStatus.Progress;
    if (stringStatus == 'error') status = UrlUploadStatus.Error;
    if (stringStatus == 'success') status = UrlUploadStatus.Success;

    return UrlUploadStatusResponse(
      status: status,
      errorMessage: json['error'],
      fileInfo: status == UrlUploadStatus.Success
          ? UploadcareFileInfo.fromJson(json)
          : null,
      progress: status == UrlUploadStatus.Progress && json['total'] != null
          ? UploadcareProgress.fromJson(json)
          : null,
    );
  }
}
