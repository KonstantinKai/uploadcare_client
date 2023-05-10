import 'base.dart';

enum DucumentOutFormatTValue {
  DOC('doc'),
  DOCX('docx'),
  XLS('xls'),
  XLSX('xlsx'),
  ODT('odt'),
  ODS('ods'),
  TXT('txt'),
  RTF('rtf'),
  PDF('pdf'),
  JPG('jpg'),
  PNG('png');

  const DucumentOutFormatTValue(this._value);

  final String _value;

  @override
  String toString() => _value;
}

/// See https://uploadcare.com/docs/transformations/document-conversion/#process
class DocumentFormatTransformation
    extends EnumTransformation<DucumentOutFormatTValue>
    implements DocumentTransformation {
  DocumentFormatTransformation(
    DucumentOutFormatTValue output, {
    int? page,
  })  : assert(
            page != null
                ? [DucumentOutFormatTValue.PNG, DucumentOutFormatTValue.JPG]
                    .contains(output)
                : true,
            'Page convert works only for "${DucumentOutFormatTValue.PNG}" and "${DucumentOutFormatTValue.JPG}" formats'),
        _page = page != null ? _DocumentFormatPageTransformation(page) : null,
        super(output);

  final _DocumentFormatPageTransformation? _page;

  @override
  String get operation => 'format';

  @override
  String get valueAsString => value?.toString() ?? '';

  @override
  List<String> get params => [
        valueAsString,
        if (_page != null) '${_page!.delimiter}$_page',
      ];
}

class _DocumentFormatPageTransformation extends IntTransformation
    implements DocumentTransformation {
  const _DocumentFormatPageTransformation(int? page) : super(page);

  @override
  String get operation => 'page';
}
