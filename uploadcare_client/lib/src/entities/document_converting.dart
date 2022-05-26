import 'convert.dart';

class DocumentConvertingResultEntity extends ConvertResultEntity {
  const DocumentConvertingResultEntity({
    required super.processedFileId,
    super.originSourceLocation,
    super.token,
  });

  factory DocumentConvertingResultEntity.fromJson(Map<String, dynamic> json) =>
      DocumentConvertingResultEntity(
        originSourceLocation: json['original_source'],
        processedFileId: json['uuid'],
        token: json['token'],
      );
}
