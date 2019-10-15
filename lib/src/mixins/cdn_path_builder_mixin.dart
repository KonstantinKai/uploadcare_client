import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

/// Provides a simple way to work with [PathTransformer]
mixin CdnPathBuilderMixin<T extends Transformation> on CndEntity {
  @protected
  PathTransformer<T> get pathTransformer;
  @protected
  String get cdnUrl;

  Uri get uri => Uri.parse(cdnUrl).replace(path: '/${pathTransformer.path}');

  String get url => uri.toString();

  bool get hasTransformations => pathTransformer.hasTransformations;

  void transform(T transformation) => pathTransformer.transform(transformation);

  void transformAll(List<T> transformations) =>
      pathTransformer.transformAll(transformations);
}
