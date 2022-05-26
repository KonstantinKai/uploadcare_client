import '../entities/entities.dart';
import '../mixins/mixins.dart';
import '../options.dart';
import '../transformations/base.dart';
import '../transformations/path_transformer.dart';

/// Provides API for working with groups
class ApiGroups with OptionsShortcutMixin, TransportHelperMixin {
  @override
  final ClientOptions options;

  ApiGroups({
    required this.options,
  });

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
  ///
  /// [limit] a preferred amount of groups in a list for a single response.
  /// [fromDate] a starting point for filtering group lists.
  /// [orderDirection] specifies the way groups are sorted in a returned list,
  Future<ListEntity<GroupInfoEntity>> list({
    int limit = 100,
    OrderDirection orderDirection = OrderDirection.Asc,
    int? offset,
    DateTime? fromDate,
  }) async {
    assert(limit > 0 && limit <= 1000, 'Should be in 1..1000 range');

    final request = createRequest(
        'GET',
        buildUri('$apiUrl/groups/', {
          'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
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

  Future<void> delete(String id) async {
    await resolveStreamedResponse(
        createRequest('DELETE', buildUri('$apiUrl/groups/$id/')).send());
  }
}
