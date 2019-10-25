import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Base object to hold Uploadcare file data
class FileInfoEntity extends Equatable {
  final bool isStored;

  /// File UUID.
  final String id;

  /// Original name of an uploaded file.
  final String filename;

  /// File MIME type.
  final String mimeType;

  /// If a file is ready and not deleted, it is available on CDN.
  final bool isReady;

  /// File size in bytes.
  final int size;

  /// Date and time when a file was uploaded.
  final DateTime datetimeUploaded;

  /// Date and time of the last store request, if any.
  final DateTime datetimeStored;

  /// Date and time when a file was removed, if any.
  final DateTime datetimeRemoved;

  /// Image meta (if a file is an image): Width and height Orientation Geolocation, from EXIF Original datetime, from EXIF Format Resolution, DPI
  final Map<String, dynamic> imageInfo;

  /// Object Recognition allows categorizing and tagging images.
  /// When using Uploadcare Object Recognition, you get a list of objects detected in your image paired with confidence levels for every object class.
  final Map<String, double> recognitionInfo;

  const FileInfoEntity({
    this.isStored,
    this.id,
    this.filename,
    this.mimeType,
    this.isReady,
    this.size,
    this.datetimeUploaded,
    this.datetimeStored,
    this.datetimeRemoved,
    this.imageInfo,
    this.recognitionInfo,
  });

  factory FileInfoEntity.fromJson(Map<String, dynamic> json) => FileInfoEntity(
        isStored: json['is_stored'] ?? json['datetime_stored'] != null,
        id: json['uuid'],
        filename: json['original_filename'],
        mimeType: json['mime_type'],
        isReady: json['is_ready'],
        size: json['size'],
        datetimeRemoved: json['datetime_removed'] != null
            ? DateTime.parse(json['datetime_removed'])
            : null,
        datetimeStored: json['datetime_stored'] != null
            ? DateTime.parse(json['datetime_stored'])
            : null,
        datetimeUploaded: json['datetime_uploaded'] != null
            ? DateTime.parse(json['datetime_uploaded'])
            : null,
        imageInfo: json['image_info'] != null
            ? (json['image_info'] as Map).cast<String, dynamic>()
            : null,
        recognitionInfo: json['rekognition_info'] != null
            ? (json['rekognition_info'] as Map).cast<String, double>()
            : null,
      );

  /// if your file is an image and can be processed via Image Processing, Please note, our processing engine does not treat all image files as such.
  /// Some of those may not be supported due to file sizes, resolutions or formats.
  /// In the case, the flag is set to false. false otherwise.
  bool get isImage => imageInfo != null;

  /// @nodoc
  @protected
  @override
  List get props => [
        isStored,
        id,
        filename,
        mimeType,
        isReady,
        size,
        datetimeRemoved,
        datetimeStored,
        datetimeUploaded,
        imageInfo,
        recognitionInfo,
      ];
}
