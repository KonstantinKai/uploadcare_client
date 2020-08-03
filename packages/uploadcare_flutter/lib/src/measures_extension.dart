import 'package:flutter/painting.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

extension DimensionsExtension on Dimensions {
  Size toSize() => Size(
        width?.toDouble() ?? double.infinity,
        height?.toDouble() ?? double.infinity,
      );
}

extension OffsetsExtension on Offsets {
  Offset toOffset() => Offset(dx.toDouble(), dy.toDouble());
}

extension FaceRectExtension on FaceRect {
  Rect toRect() => Rect.fromPoints(
      topLeft.toOffset(),
      topLeft.toOffset().translate(
            size.width?.toDouble() ?? 0,
            size.height?.toDouble() ?? 0,
          ));
}
