import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum FilesFilterValue {
  /// filter by upload date
  DatetimeUploaded,

  /// filter by size
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
