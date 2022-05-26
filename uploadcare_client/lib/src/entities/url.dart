import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'file_info.dart';
import 'progress.dart';

enum UrlUploadStatusValue {
  /// The field is set to waiting initially
  Waiting,

  /// Progress, upload is in progress.
  /// You also get the additional [ProgressEntity.total] and [ProgressEntity.uploaded] fields holding file size in bytes.
  /// [ProgressEntity.total] can be null, e.g. when an origin server does not provide the needed info.
  Progress,

  /// error, string, if your uploading from URL returns an error, the respective field contains its short description.
  Error,

  /// everything went smoothly
  Success;

  factory UrlUploadStatusValue.parse(String? value) {
    if (value == 'waiting') return UrlUploadStatusValue.Waiting;
    if (value == 'progress') return UrlUploadStatusValue.Progress;
    if (value == 'error') return UrlUploadStatusValue.Error;
    if (value == 'success') return UrlUploadStatusValue.Success;

    throw ArgumentError('Unknown stats "$value"');
  }
}

/// Provides status data from `fromUrl` uploading
class UrlUploadStatusEntity extends Equatable {
  /// Upload status
  final UrlUploadStatusValue status;

  /// Error message if status equal [UrlUploadStatusValue.Error]
  final String errorMessage;

  /// File info if status equal [UrlUploadStatusValue.Success]
  final FileInfoEntity? fileInfo;

  /// Progress info if status equal [UrlUploadStatusValue.Progress]
  final ProgressEntity? progress;

  const UrlUploadStatusEntity({
    required this.status,
    this.errorMessage = '',
    this.fileInfo,
    this.progress,
  });

  factory UrlUploadStatusEntity.fromJson(Map<String, dynamic> json) {
    final status = UrlUploadStatusValue.parse(json['status']);

    return UrlUploadStatusEntity(
      status: status,
      errorMessage: json['error'] ?? '',
      fileInfo: status == UrlUploadStatusValue.Success
          ? FileInfoEntity.fromJson(json)
          : null,
      progress: status == UrlUploadStatusValue.Progress && json['total'] != null
          ? ProgressEntity.fromJson(json)
          : null,
    );
  }

  /// @nodoc
  @protected
  @override
  List get props => [status, errorMessage, fileInfo, progress];
}
