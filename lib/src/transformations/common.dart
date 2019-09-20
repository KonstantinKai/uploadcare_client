import 'dart:ui';

class PathTransformer<T extends Transformation> {
  final String id;
  final List<T> _operations;
  final String delimiter;

  PathTransformer(
    this.id, {
    this.delimiter = '-/',
    List<T> operations,
  }) : _operations = operations ?? [];

  String get path =>
      _operations.fold<String>('$id/', (prev, next) => '$prev$delimiter$next/');

  void transform(T transformation) => _operations.add(transformation);
}

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

enum QualityTValue {
  Lightest,
  Lighter,
  Normal,
  Better,
  Best,
}

class QualityTransformation extends EnumTransformation<QualityTValue>
    implements ImageTransformation, VideoTransformation {
  QualityTransformation([QualityTValue value = QualityTValue.Normal])
      : super(value);

  String get valueAsString {
    switch (value) {
      case QualityTValue.Lightest:
        return 'lightest';
      case QualityTValue.Lighter:
        return 'lighter';
      case QualityTValue.Better:
        return 'better';
      case QualityTValue.Best:
        return 'best';
      default:
        return 'normal';
    }
  }

  @override
  String get operation => 'quality';
}

class ResizeTransformation extends Transformation {
  final Size size;

  ResizeTransformation(this.size);

  String get _width => size.width != null ? size.width.toInt().toString() : '';
  String get _height =>
      size.height != null ? size.height.toInt().toString() : '';

  @override
  String get operation => 'resize';

  @override
  List<String> get params => ['${_width}x$_height'];
}
