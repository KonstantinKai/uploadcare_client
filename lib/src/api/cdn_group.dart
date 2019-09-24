import 'package:uploadcare_client/src/api/cdn_image.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';
import 'package:uploadcare_client/src/mixins/cdn_path_builder_mixin.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

class CdnGroup extends CndEntity with CdnPathBuilderMixin<GroupTransformation> {
  final String cdnUrl;
  final PathTransformer<GroupTransformation> pathTransformer;

  CdnGroup(
    String id, {
    this.cdnUrl,
  })  : assert(id != null),
        pathTransformer = PathTransformer(id, delimiter: ''),
        super(id);

  CdnImage getImage(int index) {
    if (index > filesCount - 1)
      throw RangeError('Group contains only $filesCount files');

    return CdnImage('$id/nth/$index');
  }

  int get filesCount => int.parse(id.split('~').last);
}
