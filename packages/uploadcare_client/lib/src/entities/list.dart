import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// When you get a collection in a response, like with getting a list of files, it is paginated.
/// That is, items in the collection are returned in batches.
/// Every returned batch object is `ListEntity` instance
class ListEntity<T> extends Equatable {
  final String nextUrl;
  final String previousUrl;
  final int total;
  final int limit;
  final List<T> results;

  const ListEntity({
    /// Next page URL.
    required this.nextUrl,

    /// Previous page URL.
    required this.previousUrl,

    /// A total number of objects of the queried type.
    /// For files, the queried type depends on the stored and removed query parameters.
    required this.total,

    /// Number of objects per page.
    required this.limit,

    /// List of paginated objects. See the documentation for specific object structure, e.g., [ApiFiles.list] or [ApiGroups.list].
    required this.results,
  });

  factory ListEntity.fromJson(
    Map<String, dynamic> json,
    List<T> results,
  ) =>
      ListEntity(
        nextUrl: json['next'],
        previousUrl: json['previous'],
        limit: json['per_page'],
        total: json['total'],
        results: results,
      );

  /// @nodoc
  @protected
  @override
  List get props => [
        nextUrl,
        previousUrl,
        limit,
        total,
        results,
      ];
}
