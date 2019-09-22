import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/api/cdn_image.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';
import 'package:uploadcare_client/src/mixins/cdn_path_builder_mixin.dart';
import 'package:uploadcare_client/src/mixins/options_shortcuts_mixin.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

class CdnGroup extends CndEntity
    with OptionsShortcutMixin, CdnPathBuilderMixin<GroupTransformation> {
  final ClientOptions options;
  final PathTransformer<GroupTransformation> pathTransformer;

  CdnGroup({
    @required this.options,
    @required String id,
  })  : assert(options != null),
        pathTransformer = PathTransformer(id, delimiter: ''),
        super(id);

  CdnImage getImage(int index) {
    if (index > filesCount - 1)
      throw RangeError('Group contains only $filesCount files');

    return CdnImage(id: '$id/nth/$index', options: options);
  }

  int get filesCount => int.parse(id.split('~').last);

  String get url => uri.toString();
}
