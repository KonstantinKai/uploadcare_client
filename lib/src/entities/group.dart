import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/file_info.dart';

/// Groups are identified in a way similar to individual files.
/// A group ID consists of a UUID followed by a `~` tilde character and a group size: integer number of files in group.
/// For example, here is an identifier for a group holding 12 files,
/// `badfc9f7-f88f-4921-9cc0-22e2c08aa2da~12`
class GroupInfoEntity extends Equatable {
  /// Date and time when a group was created.
  final DateTime datetimeCreated;

  /// Date and time when files in a group were stored.
  final DateTime datetimeStored;

  /// Number of files in a group.
  final int filesCount;

  /// Group identifier.
  final String id;

  /// List of [FileInfoEntity] in a group.
  /// Deleted files are represented as null to always preserve a number of files in a group in line with a group ID.
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

  /// @nodoc
  @protected
  @override
  List get props => [
        datetimeCreated,
        datetimeStored,
        files,
        filesCount,
        id,
      ];
}
