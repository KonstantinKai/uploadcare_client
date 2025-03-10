import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum MeasureUnits {
  Percent('p'),
  Pixel('');

  const MeasureUnits(this._value);

  final String _value;

  @override
  String toString() {
    return _value;
  }
}

enum Position {
  Top('top'),
  Bottom('bottom'),
  Center('center'),
  Left('left'),
  Right('right');

  const Position(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// dart:ui [Size] replacement for non flutter project
class Dimensions extends Equatable {
  const Dimensions(
    this.width,
    this.height, {
    this.units = MeasureUnits.Pixel,
  });

  const Dimensions.square(
    int side, [
    MeasureUnits units = MeasureUnits.Pixel,
  ]) : this(
          side,
          side,
          units: units,
        );

  const Dimensions.fromWidth(int width,
      [MeasureUnits units = MeasureUnits.Pixel])
      : this(
          width,
          -1,
          units: units,
        );

  const Dimensions.fromHeight(int height,
      [MeasureUnits units = MeasureUnits.Pixel])
      : this(
          -1,
          height,
          units: units,
        );

  static const Dimensions zero = Dimensions(0, 0);

  final int width;
  final int height;
  final MeasureUnits units;

  String get _width => width > -1 && width.isFinite ? width.toString() : '';
  String get _height => height > -1 && height.isFinite ? height.toString() : '';

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        width,
        height,
        units,
      ];

  @override
  String toString() => '$_width${units}x$_height$units';
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
  List<Object> get props => [
        dx,
        dy,
        units,
      ];

  @override
  String toString() => '$dx$units,$dy$units';
}

/// Provides uploadcare face shape
class FaceRect extends Equatable {
  const FaceRect(this.topLeft, this.size);

  final Offsets topLeft;
  final Dimensions size;

  /// @nodoc
  @protected
  @override
  List<Object> get props => [
        topLeft,
        size,
      ];
}

class Coordinates extends Equatable {
  const Coordinates._({
    // ignore: unused_element_parameter
    this.offset = Offsets.zero,
    this.predefined,
  });

  const Coordinates(this.offset) : predefined = null;

  final Offsets offset;
  final Position? predefined;

  static const top = Coordinates._(predefined: Position.Top);
  static const bottom = Coordinates._(predefined: Position.Bottom);
  static const left = Coordinates._(predefined: Position.Left);
  static const right = Coordinates._(predefined: Position.Right);
  static const center = Coordinates._(predefined: Position.Center);

  @override
  String toString() => predefined?.toString() ?? offset.toString();

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        offset,
        predefined,
      ];
}

class AspectRatio extends Equatable {
  const AspectRatio(this.sideA, this.sideB);

  final int sideA;
  final int sideB;

  @override
  String toString() {
    return '$sideA:$sideB';
  }

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        sideA,
        sideB,
      ];
}

class Radii extends Equatable {
  const Radii({
    required this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
    this.units = MeasureUnits.Pixel,
  }) : assert(
          bottomLeft != null ? bottomRight != null : true,
          '"bottomRight" should be specified if "bottomLeft" is present',
        );

  const Radii.all(
    int value, [
    MeasureUnits units = MeasureUnits.Pixel,
  ]) : this(
          topLeft: value,
          units: units,
        );

  const Radii.diagonal(
    int topLeftToBottomRight,
    int topRightToBottomLeft, [
    MeasureUnits units = MeasureUnits.Pixel,
  ]) : this(
          topLeft: topLeftToBottomRight,
          topRight: topRightToBottomLeft,
          units: units,
        );

  final int topLeft;
  final int? topRight;
  final int? bottomRight;
  final int? bottomLeft;
  final MeasureUnits units;

  List<int?> get _values => [topLeft, topRight, bottomRight, bottomLeft];

  @override
  String toString() {
    return _values.where((element) => element != null).map((value) {
      return '$value$units';
    }).join(',');
  }

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        topLeft,
        topRight,
        bottomRight,
        bottomLeft,
        units,
      ];
}
