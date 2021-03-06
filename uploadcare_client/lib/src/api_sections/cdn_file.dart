import '../constants.dart';
import '../entities/cdn.dart';
import '../mixins/cdn_path_builder_mixin.dart';
import '../transformations/base.dart';
import '../transformations/path_transformer.dart';

/// Provides a simple way to work with [Transformation]
class CdnFile extends CndEntity with CdnPathBuilderMixin<Transformation> {
  @override
  final String cdnUrl;
  @override
  final PathTransformer<Transformation> pathTransformer;

  CdnFile(
    String id, {
    this.cdnUrl = kCDNEndpoint,
  })  : pathTransformer = PathTransformer(id),
        super(id);
}
