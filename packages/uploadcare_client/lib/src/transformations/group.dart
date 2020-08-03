import 'base.dart';

enum ArchiveTValue {
  /// `zip` archive
  Zip,

  /// `tar` archive
  Tar,
}

/// Gets a group as an archive: [ArchiveTValue]
class ArchiveTransformation extends EnumTransformation<ArchiveTValue>
    implements GroupTransformation {
  /// Output filename: you can either specify a name for your archive
  final String filename;

  ArchiveTransformation(ArchiveTValue value, [this.filename]) : super(value);

  @override
  String get operation => 'archive';

  @override
  List<String> get params => [
        valueAsString,
        if (filename?.isNotEmpty ?? false) filename,
      ];

  @override
  String get valueAsString => value == ArchiveTValue.Zip ? 'zip' : 'tar';

  @override
  String get delimiter => '';
}
