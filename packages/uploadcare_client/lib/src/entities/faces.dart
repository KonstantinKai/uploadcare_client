import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../measures.dart';

/// Base object to hold Face Recognition data of an image
class FacesEntity extends Equatable {
  /// Represents original image size
  final Dimensions originalSize;

  /// Faces on the original image
  final List<FaceRect> faces;

  const FacesEntity({
    @required this.originalSize,
    this.faces = const [],
  }) : assert(originalSize != null);

  factory FacesEntity.fromJson(Map<String, dynamic> json) => FacesEntity(
        originalSize: Dimensions(
          json['width'],
          json['height'],
        ),
        faces: List.from(json['faces'])
            .map((face) => FaceRect(
                  Offsets(face[0], face[1]),
                  Dimensions(face[2], face[3]),
                ))
            .toList(),
      );

  bool get hasFaces => faces.isNotEmpty;

  /// @nodoc
  @protected
  @override
  List<Object> get props => [
        originalSize,
        faces,
      ];
}
