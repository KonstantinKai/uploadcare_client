import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum FilesFilterValue {
  /// Filter by upload date
  DatetimeUploaded,

  /// Filter by size
  Size,
}

enum OrderDirection {
  Asc,
  Desc,
}

/// Provides a way to order files
class FilesOrdering extends Equatable {
  /// Order by field
  final FilesFilterValue field;
  final OrderDirection direction;

  const FilesOrdering(
    this.field, {
    this.direction = OrderDirection.Asc,
  });

  String get _fieldAsString {
    if (field == FilesFilterValue.DatetimeUploaded) return 'datetime_uploaded';

    return 'size';
  }

  String get _directionAsString => direction == OrderDirection.Desc ? '-' : '';

  /// @nodoc
  @protected
  @override
  List get props => [field, direction];

  @override
  String toString() {
    return '$_directionAsString$_fieldAsString';
  }
}

enum FilesIncludeFieldsValue {
  AppData('appdata');

  final String _value;

  const FilesIncludeFieldsValue(this._value);

  @override
  String toString() => _value;
}

class FilesIncludeFields extends Equatable {
  final List<FilesIncludeFieldsValue> predefined;

  final List<String> custom;

  const FilesIncludeFields({
    this.predefined = const [],
    this.custom = const [],
  });

  const FilesIncludeFields.withAppData()
      : this(predefined: const [FilesIncludeFieldsValue.AppData]);

  /// @nodoc
  @protected
  @override
  List<Object?> get props => [
        custom,
        predefined,
      ];

  @override
  String toString() => [
        ...predefined.map((e) => e.toString()),
        ...custom,
      ].join(',');
}

enum FilesPatternValue {
  /// ${uuid}/${auto_filename}
  Default('\${default}'),

  /// ${filename}${effects}${ext}
  AutoFilename('\${auto_filename}'),

  /// Processing operations put into a CDN URL
  Effects('\${effects}'),

  /// original filename without extension
  Filename('\${filename}'),

  /// File UUID
  Uuid('\${uuid}'),

  /// File extension, including period, e.g. .jpg
  Ext('\${ext}');

  const FilesPatternValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}
