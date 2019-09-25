import 'package:uploadcare_client/src/transformations/base.dart';

/// Provides API to collect destination URL with transformation according to Uploadcare CDN API
class PathTransformer<T extends Transformation> {
  /// resource id
  final String id;

  /// collection with [Transformation]
  final List<T> _transformations;

  /// transformation delimiter
  final String delimiter;

  PathTransformer(
    this.id, {
    this.delimiter = '-/',
    List<T> transformations,
  }) : _transformations = transformations ?? [];

  String get path => _transformations.fold<String>(
      '$id/', (prev, next) => '$prev$delimiter$next/');

  bool get hasTransformations => _transformations.isNotEmpty;

  /// add [Transformation] to collection if not exists
  void transform(T transformation) {
    if (_transformations.contains(transformation)) return;

    _transformations.add(transformation);
  }

  /// add [List] of transformations to then collection
  void transforlAll(List<T> transformations) =>
      transformations.forEach(transform);

  void sort(int compare(T a, T b)) => _transformations.sort(compare);
}
