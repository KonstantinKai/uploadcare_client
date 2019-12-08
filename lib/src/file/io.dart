import 'dart:io';

import 'package:mime_type/mime_type.dart';
import 'package:uploadcare_client/src/file/file.dart';

SharedFile createFile(dynamic file) => IOFile(file as File);

class IOFile implements SharedFile {
  final File _file;
  String _name;

  IOFile(this._file) : assert(_file != null);

  @override
  String get mimeType => mime(name);

  @override
  String get name => _name ??= Uri.parse(_file.path).pathSegments.last;

  @override
  Future<int> length() => _file.length();

  @override
  Stream<List<int>> openRead([
    int start,
    int end,
  ]) =>
      _file.openRead(start, end);
}
