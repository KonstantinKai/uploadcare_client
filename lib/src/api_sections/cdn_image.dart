import 'package:uploadcare_client/src/constants.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';
import 'package:uploadcare_client/src/mixins/cdn_path_builder_mixin.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

/// Provides a simple way to work with [ImageTransformation]
class CdnImage extends CndEntity with CdnPathBuilderMixin<ImageTransformation> {
  final String cdnUrl;
  final PathTransformer<ImageTransformation> pathTransformer;

  CdnImage(
    String id, {
    this.cdnUrl = kDefaultCdnEndpoint,
  })  : assert(id != null),
        pathTransformer = PathTransformer(id),
        super(id);
}
