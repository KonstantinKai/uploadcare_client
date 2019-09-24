import 'package:uploadcare_client/src/transformations/base.dart';

class PathTransformer<T extends Transformation> {
  final String id;
  final List<T> _transformations;
  final String delimiter;

  PathTransformer(
    this.id, {
    this.delimiter = '-/',
    List<T> transformations,
  }) : _transformations = transformations ?? [];

  String get path => _transformations.fold<String>(
      '$id/', (prev, next) => '$prev$delimiter$next/');

  bool get hasTransformations => _transformations.isNotEmpty;

  void transform(T transformation) {
    if (_transformations.contains(transformation)) return;

    _transformations.add(transformation);
  }

  void transforlAll(List<T> transformations) =>
      transformations.forEach(transform);

  void sort(int compare(T a, T b)) => _transformations.sort(compare);
}
