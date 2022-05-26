import 'base.dart';

enum ArchiveTValue {
  /// `zip` archive
  Zip('zip'),

  /// `tar` archive
  Tar('tar');

  const ArchiveTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// Gets a group as an archive: [ArchiveTValue]
///
/// See https://uploadcare.com/docs/delivery/cdn/#get-as-archive
class ArchiveTransformation extends EnumTransformation<ArchiveTValue>
    implements GroupTransformation {
  /// Output filename: you can either specify a name for your archive
  final String filename;

  ArchiveTransformation(ArchiveTValue value, [this.filename = ''])
      : super(value);

  @override
  String get operation => 'archive';

  @override
  List<String> get params => [
        valueAsString,
        if (filename.isNotEmpty) filename,
      ];

  @override
  String get valueAsString => value?.toString() ?? '';

  @override
  String get delimiter => '';
}
