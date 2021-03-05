import 'package:flutter/painting.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

extension DimensionsExtension on Dimensions {
  Size toSize() {
    final doubleWidth = width.toDouble();
    final doubleHeight = height.toDouble();

    return Size(
      doubleWidth > -1 ? doubleWidth : double.infinity,
      doubleHeight > -1 ? doubleHeight : double.infinity,
    );
  }
}

extension OffsetsExtension on Offsets {
  Offset toOffset() => Offset(dx.toDouble(), dy.toDouble());
}

extension FaceRectExtension on FaceRect {
  Rect toRect() => Rect.fromPoints(
      topLeft.toOffset(),
      topLeft.toOffset().translate(
            size.width.toDouble(),
            size.height.toDouble(),
          ));
}
