enum VideoEncodingJobStatusValue {
  Pending,
  Processing,
  Failed,
  Finished,
  Canceled,
}

class VideoEncodingJobResponse {
  final VideoEncodingJobStatusValue status;
  final VideoEncodingResultResponse result;
  final String errorMessage;

  const VideoEncodingJobResponse({
    this.status,
    this.errorMessage,
    this.result,
  });

  factory VideoEncodingJobResponse.fromJson(Map<String, dynamic> json) {
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

    return VideoEncodingJobResponse(
      status: status,
      errorMessage: json['error'],
      result: status == VideoEncodingJobStatusValue.Finished
          ? VideoEncodingResultResponse.fromJson(json['result'])
          : null,
    );
  }
}

class VideoEncodingConvertResponse {
  final List<VideoEncodingResultResponse> results;
  final Map<String, String> problems;

  const VideoEncodingConvertResponse({
    this.results,
    this.problems = const {},
  });

  factory VideoEncodingConvertResponse.fromJson(Map<String, dynamic> json) =>
      VideoEncodingConvertResponse(
        problems: json['problems'],
        results: (json['result'] as List)
            .map((item) => VideoEncodingResultResponse.fromJson(item)),
      );
}

class VideoEncodingResultResponse {
  final String originSourceLocation;
  final String processedFileId;
  final int token;
  final String thumbnailsGroupId;

  const VideoEncodingResultResponse({
    this.originSourceLocation,
    this.processedFileId,
    this.token,
    this.thumbnailsGroupId,
  });

  factory VideoEncodingResultResponse.fromJson(Map<String, dynamic> json) =>
      VideoEncodingResultResponse(
        originSourceLocation: json['original_source'],
        processedFileId: json['uuid'],
        token: json['token'],
        thumbnailsGroupId: json['thumbnails_group_uuid'],
      );
}
