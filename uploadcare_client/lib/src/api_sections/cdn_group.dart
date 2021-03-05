import '../api_sections/cdn_image.dart';
import '../constants.dart';
import '../entities/cdn.dart';
import '../mixins/cdn_path_builder_mixin.dart';
import '../transformations/base.dart';
import '../transformations/path_transformer.dart';

/// Provides a simple way to work with [GroupTransformation]
class CdnGroup extends CndEntity with CdnPathBuilderMixin<GroupTransformation> {
  @override
  final String cdnUrl;
  @override
  final PathTransformer<GroupTransformation> pathTransformer;

  CdnGroup(
    String id, {
    this.cdnUrl = kCDNEndpoint,
  })  : pathTransformer = PathTransformer(id),
        super(id);

  /// Retreive [CdnImage] from group
  /// Throws `RangeError` if index greater than [filesCount]
  CdnImage getImage(int index) {
    if (index > filesCount - 1) {
      throw RangeError('Group contains only $filesCount files');
    }

    return CdnImage('$id/nth/$index');
  }

  int get filesCount => int.parse(id.split('~').last);
}
