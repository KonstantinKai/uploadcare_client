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

  void transform(T transformation) => _transformations.add(transformation);
}
