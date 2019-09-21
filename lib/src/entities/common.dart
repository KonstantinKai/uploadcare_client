enum FilesFilterValue {
  DatetimeUploaded,
  Size,
}

enum OrderDirection {
  Asc,
  Desc,
}

class FilesOrdering {
  final FilesFilterValue field;
  final OrderDirection direction;

  const FilesOrdering(this.field, [this.direction = OrderDirection.Asc]);

  String get _fieldAsString {
    if (field == FilesFilterValue.DatetimeUploaded) return 'datetime_uploaded';

    return 'size';
  }

  String get _directionAsString => direction == OrderDirection.Desc ? '-' : '';

  @override
  String toString() {
    return '$_directionAsString$_fieldAsString';
  }
}
