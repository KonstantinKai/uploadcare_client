import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Base object to hold Face Recognition data of an image
class FacesEntity extends Equatable {
  /// Represents original image size
  final Size originalSize;

  /// Faces on the original image
  final List<Rect> faces;

  const FacesEntity({
    @required this.originalSize,
    this.faces = const [],
  }) : assert(originalSize != null);

  factory FacesEntity.fromJson(Map<String, dynamic> json) => FacesEntity(
        originalSize: Size(
          (json['width'] as int).toDouble(),
          (json['height'] as int).toDouble(),
        ),
        faces: List.from(json['faces'])
            .map((face) =>
                Offset(face[0].toDouble(), face[1].toDouble()) &
                Size(face[2].toDouble(), face[3].toDouble()))
            .toList(),
      );

  bool get hasFaces => faces.isNotEmpty;

  /// Retrieve rectangles relative to the specific size
  List<Rect> getRelativeFaces(Size size) => faces.map((face) {
        return Offset(
              face.left / originalSize.width * size.width,
              face.top / originalSize.height * size.height,
            ) &
            Size(
              face.width / originalSize.width * size.width,
              face.height / originalSize.height * size.height,
            );
      }).toList();

  /// @nodoc
  @protected
  @override
  List<Object> get props => [
        originalSize,
        faces,
      ];
}
