import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/cdn_entity.dart';
import 'package:uploadcare_client/src/mixins/mixins.dart';
import 'package:uploadcare_client/src/transformations/common.dart';

mixin CdnPathBuilderMixin<T extends Transformation>
    on UploadcareOptionsShortcutsMixin, CndEntity {
  PathTransformer _pathTransformer;

  @protected
  void initPathTransformer() => _pathTransformer = PathTransformer(id);

  Uri get uri => Uri.parse(cdnUrl).replace(path: '/${_pathTransformer.path}');

  void transform(T transformation) =>
      _pathTransformer.transform(transformation);
}
