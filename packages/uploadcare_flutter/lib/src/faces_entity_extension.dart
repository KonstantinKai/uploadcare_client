import 'package:flutter/rendering.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

extension FacesEntityExtension on FacesEntity {
  /// Retrieve rectangles relative to the specific size
  List<Rect> getRelativeFaces(Size size) => faces.map((face) {
        return Offset(
              face.topLeft.dx / originalSize.width * size.width,
              face.topLeft.dy / originalSize.height * size.height,
            ) &
            Size(
              face.size.width / originalSize.width * size.width,
              face.size.height / originalSize.height * size.height,
            );
      }).toList();
}
