import 'base.dart';

/// Provides API to collect destination URL with transformation according to Uploadcare CDN API
class PathTransformer<T extends Transformation> {
  /// Resource id
  final String id;

  /// Collection with [Transformation]
  final List<T> _transformations;

  PathTransformer(
    this.id, {
    List<T>? transformations,
  }) : _transformations = transformations ?? [];

  String get path => _transformations.fold<String>(
      '$id/', (prev, next) => '$prev${next.delimiter}$next/');

  bool get hasTransformations => _transformations.isNotEmpty;

  /// Add [Transformation] to collection if not exists
  void transform(T transformation) {
    if (_transformations.contains(transformation)) return;

    _transformations.add(transformation);
  }

  /// Add `List<T> ` of transformations to the collection
  void transformAll(List<T> transformations) =>
      transformations.forEach(transform);

  void sort(int Function(T a, T b) compare) => _transformations.sort(compare);
}
