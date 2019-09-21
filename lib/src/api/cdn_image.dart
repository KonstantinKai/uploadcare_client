import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/cdn.dart';
import 'package:uploadcare_client/src/mixins/cdn_path_builder_mixin.dart';
import 'package:uploadcare_client/src/mixins/options_shortcuts_mixin.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';

class CdnImage extends CndEntity
    with OptionsShortcutMixin, CdnPathBuilderMixin<ImageTransformation> {
  final ClientOptions options;
  final PathTransformer<ImageTransformation> pathTransformer;

  CdnImage({
    @required this.options,
    @required String id,
  })  : assert(options != null),
        pathTransformer = PathTransformer(id),
        super(id);

  @override
  String toString() => uri.toString();
}
