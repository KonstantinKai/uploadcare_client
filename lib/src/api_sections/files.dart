import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/common.dart';
import 'package:uploadcare_client/src/entities/file_info.dart';
import 'package:uploadcare_client/src/entities/list.dart';
import 'package:uploadcare_client/src/mixins/mixins.dart';
import 'package:uploadcare_client/src/options.dart';

/// Provides API for working with files
class ApiFiles with OptionsShortcutMixin, TransportHelperMixin {
  ApiFiles({
    @required this.options,
  }) : assert(options != null);

  final ClientOptions options;

  /// Retrieve file by [fileId]
  Future<FileInfoEntity> file(String fileId) async => FileInfoEntity.fromJson(
        await resolveStreamedResponse(
          createRequest(
            'GET',
            buildUri('$apiUrl/files/$fileId/'),
          ).send(),
        ),
      );

  /// Batch file delete
  Future<void> remove(List<String> fileIds) async {
    assert(fileIds.length <= 100, 'Can be removed up to 100 files per request');

    final request = createRequest(
      'DELETE',
      buildUri('$apiUrl/files/storage/'),
    )..body = jsonEncode(fileIds);

    await resolveStreamedResponseStatusCode(request.send());
  }

  /// Store files by [fileIds]
  Future<void> store(List<String> fileIds) async {
    assert(fileIds.length <= 100, 'Can be stored up to 100 files per request');

    final request = createRequest('PUT', buildUri('$apiUrl/files/storage/'))
      ..body = jsonEncode(fileIds);

    await resolveStreamedResponseStatusCode(request.send());
  }

  /// Retrieve files
  Future<ListEntity<FileInfoEntity>> list({
    /// `true` to only include files that were stored, `false` to include temporary ones.
    bool stored = true,

    /// `true` to only include removed files in the response, `false` to include existing files.
    bool removed = false,

    /// a preferred amount of files in a list for a single response.
    int limit = 100,
    int offset,

    /// specifies the way files are sorted in a returned list
    FilesOrdering ordering =
        const FilesOrdering(FilesFilterValue.DatetimeUploaded),

    /// a starting point for filtering files. The value depends on your ordering parameter value.
    dynamic fromFilter,
  }) async {
    assert(limit > 0 && limit <= 1000, 'Should be in 1..1000 range');

    if (fromFilter != null) {
      if (ordering.field == FilesFilterValue.DatetimeUploaded) {
        assert(
          fromFilter is DateTime,
          'fromFilter should be an DateTime for datetime_uploaded ordering',
        );
        fromFilter = (fromFilter as DateTime).toIso8601String();
      } else if (ordering.field == FilesFilterValue.Size) {
        assert(
          fromFilter is int && fromFilter > 0,
          'fromFilter should be an positive integer for size ordering',
        );
        fromFilter = fromFilter.toString();
      }
    }

    final response = await resolveStreamedResponse(
      createRequest(
          'GET',
          buildUri('$apiUrl/files/', {
            'limit': limit.toString(),
            'ordering': ordering.toString(),
            if (stored != null) 'stored': stored.toString(),
            if (removed != null) 'removed': removed.toString(),
            if (offset != null) 'offset': offset.toString(),
            if (fromFilter != null) 'from': fromFilter
          })).send(),
    );

    return ListEntity.fromJson(
      response,
      (response['results'] as List)
          .map((item) => FileInfoEntity.fromJson(item))
          .toList(),
    );
  }
}
