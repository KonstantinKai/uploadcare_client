import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/group.dart';
import 'package:uploadcare_client/src/entities/list.dart';
import 'package:uploadcare_client/src/mixins/mixins.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

/// Provides API for working with groups
class ApiGroups with OptionsShortcutMixin, TransportHelperMixin {
  final ClientOptions options;

  ApiGroups({
    @required this.options,
  }) : assert(options != null);

  /// Retrieve group by [id]
  Future<GroupInfoEntity> group(String id) async =>
      GroupInfoEntity.fromJson(await resolveStreamedResponse(
          createRequest('GET', buildUri('$apiUrl/groups/$id/')).send()));

  /// Mark all files in a group as stored
  Future<void> storeFiles(String id) => resolveStreamedResponseStatusCode(
      createRequest('PUT', buildUri('$apiUrl/groups/$id/storage/')).send());

  /// Create a group
  Future<GroupInfoEntity> create(
    Map<String, List<ImageTransformation>> files,
  ) async {
    assert(files.length <= 1000, 'Should be in 1..1000 range');

    final entries = files.entries.toList();
    final request =
        createMultipartRequest('POST', buildUri('$uploadUrl/group/'))
          ..fields.addAll({'pub_key': publicKey})
          ..fields.addEntries(List.generate(files.length, (index) {
            final entry = entries[index];
            final pathTransformer =
                PathTransformer(entry.key, transformations: entry.value);
            return MapEntry(
                'files[$index]',
                pathTransformer.hasTransformations
                    ? pathTransformer.path
                    : pathTransformer.id);
          }));

    return GroupInfoEntity.fromJson(
        await resolveStreamedResponse(request.send()));
  }

  /// Retrieve groups
  Future<ListEntity<GroupInfoEntity>> list({
    /// a preferred amount of groups in a list for a single response.
    int limit = 100,
    int offset,

    /// a starting point for filtering group lists.
    DateTime fromDate,

    /// specifies the way groups are sorted in a returned list,
    OrderDirection orderDirection = OrderDirection.Asc,
  }) async {
    assert(limit > 0 && limit <= 1000, 'Should be in 1..1000 range');

    final request = createRequest(
        'GET',
        buildUri('$apiUrl/groups/', {
          'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
          if (orderDirection != null)
            'ordering': orderDirection == OrderDirection.Asc
                ? 'datetime_created'
                : '-datetime_created',
          if (fromDate != null) 'from': fromDate.toIso8601String(),
        }));

    final response = await resolveStreamedResponse(request.send());

    return ListEntity.fromJson(
        response,
        (response['results'] as List)
            .map((item) => GroupInfoEntity.fromJson(item))
            .toList());
  }
}
