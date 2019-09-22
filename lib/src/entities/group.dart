import 'package:uploadcare_client/src/entities/file_info.dart';

class GroupInfoEntity {
  final DateTime datetimeCreated;
  final DateTime datetimeStored;
  final int filesCount;
  final String id;
  final List<FileInfoEntity> files;

  const GroupInfoEntity({
    this.datetimeCreated,
    this.datetimeStored,
    this.files,
    this.filesCount,
    this.id,
  });

  factory GroupInfoEntity.fromJson(Map<String, dynamic> json) =>
      GroupInfoEntity(
        datetimeCreated: DateTime.parse(json['datetime_created']),
        datetimeStored: json['datetime_stored'] != null
            ? DateTime.parse(json['datetime_stored'])
            : null,
        filesCount: json['files_count'],
        id: json['id'],
        files: json['files'] != null
            ? (json['files'] as List)
                .map((item) => FileInfoEntity.fromJson(item))
                .toList()
            : null,
      );
}
