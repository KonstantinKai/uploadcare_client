import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Dimensions extends Equatable {
  final int width;
  final int height;

  const Dimensions(this.width, this.height)
      : assert(
          width != null && height != null,
          'width & height cannot be null',
        );

  const Dimensions.square(int side) : this(side, side);

  const Dimensions.fromWidth(this.width) : height = null;

  const Dimensions.fromHeight(this.height) : width = null;

  static const Dimensions zero = Dimensions(0, 0);

  /// @nodoc
  @protected
  @override
  List<Object> get props => [width, height];
}

class Offsets extends Equatable {
  final int dx;
  final int dy;

  const Offsets(this.dx, this.dy)
      : assert(
          dx != null && dy != null,
          'dx & dy cannot be null',
        );

  static const Offsets zero = Offsets(0, 0);

  /// @nodoc
  @protected
  @override
  List<Object> get props => [dx, dy];
}

class FaceRect extends Equatable {
  final Offsets topLeft;
  final Dimensions size;

  const FaceRect(this.topLeft, this.size)
      : assert(
          topLeft != null && size != null,
          'leftTop & size cannot be null',
        );

  @override
  List<Object> get props => [
        topLeft,
        size,
      ];
}
