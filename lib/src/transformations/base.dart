abstract class Transformation {
  String get operation;
  List<String> get params;

  @override
  String toString() => [operation, ...params].join('/');
}

abstract class ImageTransformation implements Transformation {}

abstract class VideoTransformation implements Transformation {}

abstract class EnumTransformation<T> extends Transformation {
  final T value;

  EnumTransformation(this.value);

  String get valueAsString;

  @override
  List<String> get params => [valueAsString];
}

abstract class BooleanTransformation extends Transformation {
  final bool value;

  BooleanTransformation(this.value);

  @override
  List<String> get params => [value ? 'yes' : 'no'];
}

abstract class IntTransformation extends Transformation {
  final int value;

  IntTransformation(this.value);

  @override
  List<String> get params => [value.toString()];
}

abstract class NullParamTransformation extends Transformation {
  @override
  List<String> get params => [];
}
