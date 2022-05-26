import 'package:meta/meta.dart';
import '../entities/cdn.dart';
import '../transformations/base.dart';
import '../transformations/path_transformer.dart';

/// Provides a simple way to work with [PathTransformer]
@internal
mixin CdnPathBuilderMixin<T extends Transformation> on CndEntity {
  @protected
  PathTransformer<T> get pathTransformer;
  @protected
  String get cdnUrl;

  Uri get uri => Uri.parse(
      '${cdnUrl.replaceFirst(RegExp(r'/$'), '')}/${pathTransformer.path}');

  String get url => uri.toString();

  bool get hasTransformations => pathTransformer.hasTransformations;

  void transform(T transformation) => pathTransformer.transform(transformation);

  void transformAll(List<T> transformations) =>
      pathTransformer.transformAll(transformations);
}
