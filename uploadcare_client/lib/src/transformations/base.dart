/// Base class for accessing the Uploadcare CDN API
abstract class Transformation {
  const Transformation();

  /// CDN API operation URL directive
  String get operation;

  /// Related parameters
  List<String> get params;

  /// Instruction delimiter
  String get delimiter => '-/';

  @override
  String toString() => [operation, ...params].join('/');

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// An abstraction for image transformations
abstract class ImageTransformation implements Transformation {}

/// An abstraction for video transformations
abstract class VideoTransformation implements Transformation {}

/// An abstraction for group transformations
abstract class GroupTransformation implements Transformation {}

/// An abstraction for document transformations
abstract class DocumentTransformation implements Transformation {}

/// An abstraction to make transformation implementation with `enum` values
abstract class EnumTransformation<T> extends Transformation {
  const EnumTransformation(this.value);

  final T? value;

  String get valueAsString;

  @override
  List<String> get params => [valueAsString];
}

/// An abstraction to make transformation implementation with [bool] values which transforms to `yes/no` string
abstract class BooleanTransformation extends Transformation {
  const BooleanTransformation(this.value);

  final bool value;

  @override
  List<String> get params => [value ? 'yes' : 'no'];
}

/// An abstraction to make transformation implementation with [int] values
abstract class IntTransformation extends Transformation {
  const IntTransformation(this.value);

  final int? value;

  @override
  List<String> get params => [
        if (value != null) value.toString(),
      ];
}

/// An abstraction to make transformation implementation with no parameters
abstract class NullParamTransformation extends Transformation {
  @override
  List<String> get params => [];
}
