import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';
import 'package:uploadcare_client/src/mixins/cdn_path_builder_mixin.dart';
import 'package:uploadcare_client/src/mixins/options_shortcuts_mixin.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

class CdnVideo extends CndEntity
    with OptionsShortcutMixin, CdnPathBuilderMixin<VideoTransformation> {
  final ClientOptions options;
  final PathTransformer<VideoTransformation> pathTransformer;

  CdnVideo({
    @required this.options,
    @required String id,
  })  : assert(options != null),
        pathTransformer = PathTransformer('$id/video'),
        super(id);

  @override
  String toString() => uri.toString();
}
