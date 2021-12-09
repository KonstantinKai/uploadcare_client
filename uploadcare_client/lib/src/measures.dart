import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum MeasureUnits {
  Percent,
  Pixel,
}

/// dart:ui [Size] replacement for non flutter project
class Dimensions extends Equatable {
  const Dimensions(
    this.width,
    this.height, {
    this.units = MeasureUnits.Pixel,
  });

  const Dimensions.square(int side) : this(side, side);

  const Dimensions.fromWidth(int width) : this(width, -1);

  const Dimensions.fromHeight(int height) : this(-1, height);

  static const Dimensions zero = Dimensions(0, 0);

  final int width;
  final int height;
  final MeasureUnits units;

  String get _width => width > -1 && width.isFinite ? width.toString() : '';
  String get _height => height > -1 && height.isFinite ? height.toString() : '';

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [width, height, units];

  @override
  String toString() {
    if (units == MeasureUnits.Percent) {
      return '${_width}px${_height}p';
    }

    return '${_width}x$_height';
  }
}

/// dart:ui [Offset] replacement for non flutter project
class Offsets extends Equatable {
  const Offsets(
    this.dx,
    this.dy, {
    this.units = MeasureUnits.Pixel,
  });

  static const Offsets zero = Offsets(0, 0);

  final int dx;
  final int dy;
  final MeasureUnits units;

  /// @nodoc
  @protected
  @override
  List<Object> get props => [dx, dy, units];

  @override
  String toString() {
    if (units == MeasureUnits.Percent) {
      return '${dx}p,${dy}p';
    }

    return '$dx,$dy';
  }
}

/// Provides uploadcare face shape
class FaceRect extends Equatable {
  const FaceRect(this.topLeft, this.size);

  final Offsets topLeft;
  final Dimensions size;

  @override
  List<Object> get props => [topLeft, size];
}

class Coordinates extends Equatable {
  const Coordinates._({
    this.offset = Offsets.zero,
    this.predefined,
  });

  const Coordinates(this.offset) : predefined = null;

  final Offsets offset;
  final String? predefined;

  static const top = Coordinates._(predefined: 'top');
  static const bottom = Coordinates._(predefined: 'bottom');
  static const left = Coordinates._(predefined: 'left');
  static const right = Coordinates._(predefined: 'right');
  static const center = Coordinates._(predefined: 'center');

  @override
  String toString() => predefined ?? offset.toString();

  @override
  List<Object?> get props => [
        offset,
        predefined,
      ];
}
