class FileInfoEntity {
  final bool isStored;
  final String id;
  final String filename;
  final String mimeType;
  final bool isReady;
  final int size;
  final DateTime datetimeUploaded;
  final DateTime datetimeStored;
  final DateTime datetimeRemoved;
  final ImageInfoEntity imageInfo;

  FileInfoEntity({
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
        imageInfo: ImageInfoEntity.fromJson(json['image_info']),
      );

  bool get isImage => imageInfo != null;
}

class ImageInfoEntity {
  final String format;
  final int width;
  final int height;

  ImageInfoEntity({
    this.format,
    this.width,
    this.height,
  });

  factory ImageInfoEntity.fromJson(Map<String, dynamic> json) => json != null
      ? ImageInfoEntity(
          format: json['format'],
          width: json['width'],
          height: json['height'],
        )
      : null;
}
