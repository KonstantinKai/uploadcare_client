import 'package:meta/meta.dart';

import 'convert.dart';

/// Provides converting result data
class VideoEncodingResultEntity extends ConvertResultEntity {
  /// Holds `groupId`, a UUID of a file group with thumbnails for an output video, based on the thumbs operation parameters.
  final String thumbnailsGroupId;

  const VideoEncodingResultEntity({
    required super.processedFileId,
    required this.thumbnailsGroupId,
    super.originSourceLocation,
    super.token,
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
        ...super.props,
        thumbnailsGroupId,
      ];
}
