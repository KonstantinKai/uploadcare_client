import 'package:uploadcare_client/src/transformations/base.dart';

enum ArchiveTValue {
  Zip,
  Tar,
}

class ArchiveTransformation extends EnumTransformation<ArchiveTValue>
    implements GroupTransformation {
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
}
