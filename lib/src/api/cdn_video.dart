import 'package:meta/meta.dart';
import 'package:uploadcare_client/src/entities/cdn_entity.dart';
import 'package:uploadcare_client/src/mixins/cdn_path_builder_mixin.dart';
import 'package:uploadcare_client/src/mixins/options_shortcuts_mixin.dart';
import 'package:uploadcare_client/src/options.dart';
import 'package:uploadcare_client/src/transformations/common.dart';

class UploadcareCdnVideo extends CndEntity
    with
        UploadcareOptionsShortcutsMixin,
        CdnPathBuilderMixin<VideoTransformation> {
  final UploadcareOptions options;

  UploadcareCdnVideo({
    @required this.options,
    @required String id,
  })  : assert(options != null),
        super(id) {
    initPathTransformer();
  }

  @override
  String get id => '${super.id}/video';

  @override
  String toString() => uri.toString();
}
