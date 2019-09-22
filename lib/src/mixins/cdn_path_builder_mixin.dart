import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';
import 'package:uploadcare_client/src/mixins/mixins.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

mixin CdnPathBuilderMixin<T extends Transformation>
    on OptionsShortcutMixin, CndEntity {
  @protected
  PathTransformer<T> get pathTransformer;

  Uri get uri => Uri.parse(cdnUrl).replace(path: '/${pathTransformer.path}');

  bool get hasTransformations => pathTransformer.hasTransformations;

  void transform(T transformation) => pathTransformer.transform(transformation);
}
