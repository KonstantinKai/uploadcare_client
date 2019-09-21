import 'package:uploadcare_client/src/entities/file_info.dart';
import 'package:uploadcare_client/src/entities/progress.dart';

enum UrlUploadStatusValue {
  Progress,
  Error,
  Success,
}

class UrlUploadStatusEntity {
  final UrlUploadStatusValue status;
  final String errorMessage;
  final FileInfoEntity fileInfo;
  final ProgressEntity progress;

  const UrlUploadStatusEntity({
    this.status,
    this.errorMessage,
    this.fileInfo,
    this.progress,
  });

  factory UrlUploadStatusEntity.fromJson(Map<String, dynamic> json) {
    final stringStatus = json['status'];
    UrlUploadStatusValue status;

    if (stringStatus == 'progress') status = UrlUploadStatusValue.Progress;
    if (stringStatus == 'error') status = UrlUploadStatusValue.Error;
    if (stringStatus == 'success') status = UrlUploadStatusValue.Success;

    return UrlUploadStatusEntity(
      status: status,
      errorMessage: json['error'],
      fileInfo: status == UrlUploadStatusValue.Success
          ? FileInfoEntity.fromJson(json)
          : null,
      progress: status == UrlUploadStatusValue.Progress && json['total'] != null
          ? ProgressEntity.fromJson(json)
          : null,
    );
  }
}
