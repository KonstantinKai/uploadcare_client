import 'package:uploadcare_client/src/constants.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';
import 'package:uploadcare_client/src/mixins/cdn_path_builder_mixin.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

/// Provides a simple way to work with [Transformation]
class CdnFile extends CndEntity with CdnPathBuilderMixin<Transformation> {
  final String cdnUrl;
  final PathTransformer<Transformation> pathTransformer;

  CdnFile(
    String id, {
    this.cdnUrl = kDefaultCdnEndpoint,
  })  : assert(id != null),
        pathTransformer = PathTransformer(id),
        super(id);
}
