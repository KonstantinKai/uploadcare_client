class ListEntity<T> {
  final String nextUrl;
  final String previousUrl;
  final int total;
  final int limit;
  final List<T> results;

  const ListEntity({
    this.nextUrl,
    this.previousUrl,
    this.total,
    this.limit,
    this.results,
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
}
