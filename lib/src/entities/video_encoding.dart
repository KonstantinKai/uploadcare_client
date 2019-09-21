enum VideoEncodingJobStatusValue {
  Pending,
  Processing,
  Failed,
  Finished,
  Canceled,
}

class VideoEncodingJobEntity {
  final VideoEncodingJobStatusValue status;
  final VideoEncodingResultEntity result;
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
}

class VideoEncodingConvertEntity {
  final List<VideoEncodingResultEntity> results;
  final Map<String, String> problems;

  const VideoEncodingConvertEntity({
    this.results,
    this.problems = const {},
  });

  factory VideoEncodingConvertEntity.fromJson(Map<String, dynamic> json) =>
      VideoEncodingConvertEntity(
        problems: json['problems'],
        results: (json['result'] as List)
            .map((item) => VideoEncodingResultEntity.fromJson(item)),
      );
}

class VideoEncodingResultEntity {
  final String originSourceLocation;
  final String processedFileId;
  final int token;
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
}
