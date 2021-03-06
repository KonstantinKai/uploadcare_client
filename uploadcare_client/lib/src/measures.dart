import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// dart:ui [Size] replacement for non flutter project
class Dimensions extends Equatable {
  final int width;
  final int height;

  const Dimensions(this.width, this.height);

  const Dimensions.square(int side) : this(side, side);

  const Dimensions.fromWidth(this.width) : height = -1;

  const Dimensions.fromHeight(this.height) : width = -1;

  static const Dimensions zero = Dimensions(0, 0);

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [width, height];
}

/// dart:ui [Offset] replacement for non flutter project
class Offsets extends Equatable {
  final int dx;
  final int dy;

  const Offsets(this.dx, this.dy);

  static const Offsets zero = Offsets(0, 0);

  /// @nodoc
  @protected
  @override
  List<Object> get props => [dx, dy];
}

/// Provides uploadcare face shape
class FaceRect extends Equatable {
  final Offsets topLeft;
  final Dimensions size;

  const FaceRect(this.topLeft, this.size);

  @override
  List<Object> get props => [topLeft, size];
}
