class UploadcareFileInfo {
  UploadcareFileInfo({
    this.isStored,
    this.id,
    this.filename,
    this.mimeType,
    this.isReady,
    this.size,
    this.imageInfo,
  });

  factory UploadcareFileInfo.fromJson(Map<String, dynamic> json) =>
      UploadcareFileInfo(
        isStored: json['is_stored'],
        id: json['file_id'],
        filename: json['filename'],
        mimeType: json['mime_type'],
        isReady: json['is_ready'],
        size: json['size'],
        imageInfo: UploadcareImageInfo.fromJson(json['image_info']),
      );

  final bool isStored;
  final String id;
  final String filename;
  final String mimeType;
  final bool isReady;
  final int size;
  final UploadcareImageInfo imageInfo;

  bool get isImage => imageInfo != null;
}

class UploadcareImageInfo {
  UploadcareImageInfo({
    this.format,
    this.width,
    this.height,
  });

  factory UploadcareImageInfo.fromJson(Map<String, dynamic> json) =>
      json != null
          ? UploadcareImageInfo(
              format: json['format'],
              width: json['width'],
              height: json['height'],
            )
          : null;

  final String format;
  final int width;
  final int height;
}
