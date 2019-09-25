import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum VideoEncodingJobStatusValue {
  /// Video file is being prepared for conversion.
  Pending,

  /// Video file processing is in progress.
  Processing,

  /// We failed to process the video, see [VideoEncodingJobEntity.errorMessage] for details.
  Failed,

  /// The processing is finished.
  Finished,

  /// Video processing was canceled.
  Canceled,
}

/// Provides status data for converting job
class VideoEncodingJobEntity extends Equatable {
  /// Encoding job status
  final VideoEncodingJobStatusValue status;
  final VideoEncodingResultEntity result;

  /// Holds a processing error message
  final String errorMessage;

  const VideoEncodingJobEntity({
    this.status,
    this.errorMessage,
    this.result,
  });

  factory VideoEncodingJobEntity.fromJson(Map<String, dynamic> json) {
    final strignStatus = json['status'];
    VideoEncodingJobStatusValue status;

    if (strignStatus == 'pending') status = VideoEncodingJobStatusValue.Pending;
    if (strignStatus == 'processing')
      status = VideoEncodingJobStatusValue.Processing;
    if (strignStatus == 'finished')
      status = VideoEncodingJobStatusValue.Finished;
    if (strignStatus == 'failed') status = VideoEncodingJobStatusValue.Failed;
    if (strignStatus == 'canceled')
      status = VideoEncodingJobStatusValue.Canceled;

    return VideoEncodingJobEntity(
      status: status,
      errorMessage: json['error'],
      result: status == VideoEncodingJobStatusValue.Finished
          ? VideoEncodingResultEntity.fromJson(json['result'])
          : null,
    );
  }

  /// @nodoc
  @protected
  @override
  List get props => [status, errorMessage, result];
}

/// Provides response data from convert job
class VideoEncodingConvertEntity extends Equatable {
  final List<VideoEncodingResultEntity> results;

  /// Problems related to your processing job, if any.
  final Map<String, String> problems;

  const VideoEncodingConvertEntity({
    this.results,
    this.problems = const {},
  });

  factory VideoEncodingConvertEntity.fromJson(Map<String, dynamic> json) =>
      VideoEncodingConvertEntity(
        problems: (json['problems'] as Map).cast<String, String>(),
        results: (json['result'] as List)
            .map((item) => VideoEncodingResultEntity.fromJson(item))
            .toList(),
      );

  /// @nodoc
  @protected
  @override
  List get props => [results, problems];
}

/// Provides converting result data
class VideoEncodingResultEntity extends Equatable {
  /// Input file identifier including transformations, if present.
  final String originSourceLocation;

  /// A UUID of your processed video file.
  final String processedFileId;

  /// A processing job token that can be used to get a job status
  final int token;

  /// Holds `groupId`, a UUID of a file group with thumbnails for an output video, based on the thumbs operation parameters.
  final String thumbnailsGroupId;

  const VideoEncodingResultEntity({
    this.originSourceLocation,
    this.processedFileId,
    this.token,
    this.thumbnailsGroupId,
  });

  factory VideoEncodingResultEntity.fromJson(Map<String, dynamic> json) =>
      VideoEncodingResultEntity(
        originSourceLocation: json['original_source'],
        processedFileId: json['uuid'],
        token: json['token'],
        thumbnailsGroupId: json['thumbnails_group_uuid'],
      );

  /// @nodoc
  @protected
  @override
  List get props => [
        originSourceLocation,
        processedFileId,
        token,
        thumbnailsGroupId,
      ];
}
