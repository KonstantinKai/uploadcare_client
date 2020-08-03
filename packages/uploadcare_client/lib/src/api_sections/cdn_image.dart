import '../constants.dart';
import '../entities/cdn.dart';
import '../mixins/cdn_path_builder_mixin.dart';
import '../transformations/base.dart';
import '../transformations/path_transformer.dart';

/// Provides a simple way to work with [ImageTransformation]
class CdnImage extends CndEntity with CdnPathBuilderMixin<ImageTransformation> {
  @override
  final String cdnUrl;
  @override
  final PathTransformer<ImageTransformation> pathTransformer;

  CdnImage(
    String id, {
    this.cdnUrl = kCDNEndpoint,
  })  : assert(id != null),
        pathTransformer = PathTransformer(id),
        super(id);
}
