import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'addons.dart';

import '../measures.dart' show Dimensions;

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
  final DateTime? datetimeUploaded;

  /// Date and time of the last store request, if any.
  final DateTime? datetimeStored;

  /// Date and time when a file was removed, if any.
  final DateTime? datetimeRemoved;

  /// Image meta. See [ImageInfo]
  final ImageInfo? imageInfo;

  /// **Since v0.6**
  ///
  /// Video metadata. See [VideoInfo]
  final VideoInfo? videoInfo;

  /// **Only v0.6**
  ///
  /// Object Recognition allows categorizing and tagging images.
  /// When using Uploadcare Object Recognition, you get a list of objects detected in your image paired with confidence levels for every object class.
  @Deprecated(
      'Due to the API stabilizing recognition info moved to the [AppData.awsRecognition]')
  final Map<String, double>? recognitionInfo;

  /// **Since v0.7**
  ///
  /// File Metadata is additional, arbitrary data, associated with uploaded file. As an example, you could store unique file identifier from your system.
  final Map<String, String>? metadata;

  /// **Since v0.6**
  ///
  /// Dictionary of other files that were created using this file as a source. It's used for video processing and document conversion jobs.
  /// E.g., <conversion_path>: <uuid>.
  final Map<String, String>? variations;

  /// **Since v0.7**
  ///
  /// Dictionary of application names and data associated with these applications.
  final AppData? appData;

  const FileInfoEntity({
    required this.isStored,
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.isReady,
    required this.size,
    this.datetimeUploaded,
    this.datetimeStored,
    this.datetimeRemoved,
    this.imageInfo,
    this.videoInfo,
    this.recognitionInfo,
    this.metadata,
    this.variations,
    this.appData,
  });

  /// If your file is an image and can be processed via Image Processing, Please note, our processing engine does not treat all image files as such.
  /// Some of those may not be supported due to file sizes, resolutions or formats.
  /// In the case, the flag is set to false. false otherwise.
  bool get isImage => imageInfo != null;

  bool get isVideo => videoInfo != null;

  /// @nodoc
  @protected
  @override
  List get props => [
        isStored,
        id,
        filename,
        isReady,
        size,
        datetimeRemoved,
        datetimeStored,
        datetimeUploaded,
        imageInfo,
        videoInfo,
        // ignore: deprecated_member_use_from_same_package
        recognitionInfo,
        metadata,
        variations,
        appData,
      ];

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
          ? ImageInfo.fromJson(
              (json['image_info'] as Map).cast<String, dynamic>(),
            )
          : json['content_info'] != null &&
                  json['content_info']['image'] != null
              ? ImageInfo.fromJson(
                  (json['content_info']['image'] as Map)
                      .cast<String, dynamic>(),
                )
              : null,
      videoInfo: json['video_info'] != null
          ? VideoInfo.fromJson(
              (json['video_info'] as Map).cast<String, dynamic>(),
            )
          : json['content_info'] != null &&
                  json['content_info']['video'] != null
              ? VideoInfo.fromJson(
                  (json['content_info']['video'] as Map)
                      .cast<String, dynamic>(),
                )
              : null,
      recognitionInfo: json['rekognition_info'] != null
          ? (json['rekognition_info'] as Map).cast<String, double>()
          : null,
      metadata: json['metadata'] != null
          ? (json['metadata'] as Map).isNotEmpty
              ? (json['metadata'] as Map).cast<String, String>()
              : null
          : null,
      variations: json['variations'] != null
          ? (json['variations'] as Map).cast<String, String>()
          : null,
      appData: json['appdata'] != null
          ? AppData.fromJson(
              (json['appdata'] as Map).cast<String, dynamic>(),
            )
          : null);
}

enum ImageColorMode {
  RGB,
  RGBA,
  RGBa,
  RGBX,
  L,
  LA,
  La,
  P,
  PA,
  CMYK,
  YCbCr,
  HSV,
  LAB;

  factory ImageColorMode.parse(String? color) {
    if (color == 'RGB') return ImageColorMode.RGB;
    if (color == 'RGBA') return ImageColorMode.RGBA;
    if (color == 'RGBa') return ImageColorMode.RGBa;
    if (color == 'RGBX') return ImageColorMode.RGBX;
    if (color == 'L') return ImageColorMode.L;
    if (color == 'LA') return ImageColorMode.LA;
    if (color == 'La') return ImageColorMode.La;
    if (color == 'P') return ImageColorMode.P;
    if (color == 'PA') return ImageColorMode.PA;
    if (color == 'CMYK') return ImageColorMode.CMYK;
    if (color == 'YCbCr') return ImageColorMode.YCbCr;
    if (color == 'HSV') return ImageColorMode.HSV;
    if (color == 'LAB') return ImageColorMode.LAB;

    throw ArgumentError('Unknown color mode "color"');
  }
}

class ImageInfoGeoLocation extends Equatable {
  /// Location latitude
  final num latitude;

  /// Location longitude
  final num longitude;

  const ImageInfoGeoLocation(this.latitude, this.longitude);

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        latitude,
        longitude,
      ];

  @override
  String toString() => 'lat: $latitude, lng: $longitude';
}

class ImageInfo extends Equatable {
  /// Image color mode
  final ImageColorMode? colorMode;

  /// Image orientation from EXIF
  final int? orientation;

  /// Image format
  final String format;

  /// Set to true if a file contains a sequence of images (GIF for example)
  final bool sequence;

  /// Image size
  final Dimensions size;

  /// Geo-location of image from EXIF
  final ImageInfoGeoLocation? geoLocation;

  /// Image date and time from EXIF
  final DateTime? datetimeOriginal;

  /// Image DPI for two dimensions
  final List<int>? dpi;

  const ImageInfo({
    this.colorMode,
    this.orientation,
    required this.format,
    required this.sequence,
    required this.size,
    this.geoLocation,
    this.datetimeOriginal,
    this.dpi,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        colorMode,
        orientation,
        format,
        sequence,
        size,
        geoLocation,
        datetimeOriginal,
        dpi,
      ];

  factory ImageInfo.fromJson(Map<String, dynamic> json) => ImageInfo(
        colorMode: json['color_mode'] != null
            ? ImageColorMode.parse(json['color_mode'])
            : null,
        format: json['format'],
        sequence: json['sequence'],
        size: Dimensions(json['width'], json['height']),
        orientation: json['orientation'],
        dpi: (json['dpi'] as List?)?.cast<int>(),
        datetimeOriginal: json['datetime_original'] != null
            ? DateTime.parse(json['datetime_original'])
            : null,
        geoLocation: json['geo_location'] != null
            ? ImageInfoGeoLocation(
                json['geo_location']['latitude'],
                json['geo_location']['longitude'],
              )
            : null,
      );
}

class AudioStreamMetadata extends Equatable {
  /// Audio stream's bitrate
  final int? bitrate;

  /// Audio stream's codec
  final String? codec;

  /// Audio stream's sample rate
  final int? sampleRate;

  /// Audio stream's number of channels
  final int? channels;

  const AudioStreamMetadata({
    this.bitrate,
    this.codec,
    this.sampleRate,
    this.channels,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        bitrate,
        codec,
        sampleRate,
        channels,
      ];
}

class VideoStreamMetadata extends Equatable {
  /// Video stream's image size
  final Dimensions size;

  /// Video stream's frame rate
  final num frameRate;

  /// Video stream's bitrate
  final int? bitrate;

  /// Video stream codec
  final String codec;

  const VideoStreamMetadata({
    required this.size,
    required this.frameRate,
    required this.codec,
    this.bitrate,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        size,
        frameRate,
        bitrate,
        codec,
      ];
}

class VideoInfo extends Equatable {
  /// Video file's duration
  final Duration duration;

  /// Video file's format
  final String format;

  /// Video file's bitrate
  final int bitrate;

  /// Audio stream's metadata
  final AudioStreamMetadata? audio;

  /// Video stream's metadata
  final VideoStreamMetadata video;

  const VideoInfo({
    required this.duration,
    required this.format,
    required this.bitrate,
    required this.video,
    this.audio,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        duration,
        format,
        bitrate,
        audio,
        video,
      ];

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    final videoMetadata = json['video'] is List
        ? (json['video'] as List).cast<Map<String, dynamic>>().first
        : (json['video'] as Map).cast<String, dynamic>();
    final audioMetadata = json['audio'] != null
        ? json['audio'] is List
            ? (json['audio'] as List).isNotEmpty
                ? (json['audio'] as List).cast<Map<String, dynamic>>().first
                : null
            : (json['audio'] as Map).cast<String, dynamic>()
        : null;

    return VideoInfo(
      duration: Duration(milliseconds: json['duration']),
      format: json['format'],
      bitrate: json['bitrate'],
      video: VideoStreamMetadata(
        size: Dimensions(videoMetadata['width'], videoMetadata['height']),
        frameRate: videoMetadata['frame_rate'],
        bitrate: videoMetadata['bitrate'],
        codec: videoMetadata['codec'],
      ),
      audio: audioMetadata != null
          ? AudioStreamMetadata(
              bitrate: audioMetadata['bitrate'],
              channels: audioMetadata['channels'] is String
                  ? int.tryParse(audioMetadata['channels'])
                  : audioMetadata['channels'],
              codec: audioMetadata['codec'],
              sampleRate: audioMetadata['sample_rate'],
            )
          : null,
    );
  }
}

class AppData extends Equatable {
  final AWSRekognitionAddonResult? awsRecognition;

  final ClamAVAddonResult? clamAV;

  final RemoveBgAddonResult? removeBg;

  const AppData({
    this.awsRecognition,
    this.clamAV,
    this.removeBg,
  });

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        awsRecognition,
        clamAV,
        removeBg,
      ];

  factory AppData.fromJson(Map<String, dynamic> json) {
    AWSRekognitionAddonResult? awsRecognition;
    ClamAVAddonResult? clamAV;
    RemoveBgAddonResult? removeBg;

    if (json['aws_rekognition_detect_labels'] != null) {
      awsRecognition = AWSRekognitionAddonResult(
        info: AddonResultInfo.fromJson(json['aws_rekognition_detect_labels']),
        labelModelVersion: json['aws_rekognition_detect_labels']['data']
            ['LabelModelVersion'],
        labels:
            (json['aws_rekognition_detect_labels']['data']['Labels'] as List)
                .map(
                  (item) => AWSRecognitionLabel(
                    confidence: item['Confidence'],
                    name: item['Name'],
                    instances: (item['Instances'] as List)
                        .map(
                          (instance) => AWSRecognitionInstance(
                            boundingBox: ASWRecognitionBoundingBox(
                              top: instance['BoundingBox']['Top'],
                              left: instance['BoundingBox']['Left'],
                              width: instance['BoundingBox']['Width'],
                              height: instance['BoundingBox']['Height'],
                            ),
                            confidence: instance['Confidence'],
                          ),
                        )
                        .toList(),
                    parents: (item['Parents'] as List)
                        .map((parent) => parent['Name'] as String)
                        .toList(),
                  ),
                )
                .toList(),
      );
    }

    if (json['uc_clamav_virus_scan'] != null) {
      clamAV = ClamAVAddonResult(
        info: AddonResultInfo.fromJson(json['uc_clamav_virus_scan']),
        infected: json['uc_clamav_virus_scan']['data']['infected'],
        infectedWith:
            json['uc_clamav_virus_scan']['data']['infected_with'] ?? '',
      );
    }

    if (json['remove_bg'] != null) {
      removeBg = RemoveBgAddonResult(
        info: AddonResultInfo.fromJson(json['remove_bg']),
        foregroundType: json['remove_bg']['data']['foreground_type'] as String,
      );
    }

    return AppData(
      awsRecognition: awsRecognition,
      clamAV: clamAV,
      removeBg: removeBg,
    );
  }
}
