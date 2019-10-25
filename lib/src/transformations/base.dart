/// Base class for accessing the Uploadcare CDN API
abstract class Transformation {
  /// CDN API operation URL directive
  String get operation;

  /// related parameters
  List<String> get params;

  String get delimiter => '-/';

  @override
  String toString() => [operation, ...params].join('/');

  bool operator ==(dynamic other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// An abstraction for image transformations
abstract class ImageTransformation implements Transformation {}

/// An abstraction for video transformations
abstract class VideoTransformation implements Transformation {}

/// An abstraction for group transformations
abstract class GroupTransformation implements Transformation {}

/// An abstraction to make transformation implementation with `enum` values
abstract class EnumTransformation<T> extends Transformation {
  final T value;

  EnumTransformation(this.value)
      : assert(value != null, 'Should be non-null enum value');

  String get valueAsString;

  @override
  List<String> get params => [valueAsString];
}

/// An abstraction to make transformation implementation with [bool] values which transforms to `yes/no` string
abstract class BooleanTransformation extends Transformation {
  final bool value;

  BooleanTransformation(this.value)
      : assert(value != null, 'Should be non-null boolean value');

  @override
  List<String> get params => [value ? 'yes' : 'no'];
}

/// An abstraction to make transformation implementation with [int] values
abstract class IntTransformation extends Transformation {
  final int value;

  IntTransformation(this.value)
      : assert(value != null, 'Should be an non-null integer');

  @override
  List<String> get params => [value.toString()];
}

/// An abstraction to make transformation implementation with no parameters
abstract class NullParamTransformation extends Transformation {
  @override
  List<String> get params => [];
}
