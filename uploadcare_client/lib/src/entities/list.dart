import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// When you get a collection in a response, like with getting a list of files, it is paginated.
/// That is, items in the collection are returned in batches.
/// Every returned batch object is `ListEntity` instance
class ListEntity<T> extends Equatable {
  /// Next page URL
  final String? nextUrl;

  /// Previous page URL
  final String? previousUrl;

  /// Total number of the files of the queried type. The queried type depends on the stored and removed query parameters
  final int total;

  /// Number of the files per page
  final int limit;

  final List<T> results;

  /// **Since v0.6**
  final ListEntityTotals? totals;

  const ListEntity({
    required this.total,
    required this.limit,
    required this.results,
    this.nextUrl,
    this.previousUrl,
    this.totals,
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
        totals: json['totals'] != null
            ? ListEntityTotals(
                removed: json['totals']['removed'],
                stored: json['totals']['stored'],
                unstored: json['totals']['unstored'],
              )
            : null,
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
        totals,
      ];
}

class ListEntityTotals extends Equatable {
  /// Total number of the files that are marked as removed
  final int removed;

  /// Total number of the files that are marked as stored
  final int stored;

  /// Total number of the files that are not marked as stored
  final int unstored;

  const ListEntityTotals({
    this.removed = 0,
    this.stored = 0,
    this.unstored = 0,
  });

  @override
  List<Object?> get props => [
        removed,
        stored,
        unstored,
      ];
}
