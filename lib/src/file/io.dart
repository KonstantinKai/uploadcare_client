import 'dart:io';

import 'package:mime_type/mime_type.dart';
import 'package:uploadcare_client/src/file/file.dart';

SharedFile createFile(Object file) => _IOFile(file as File);

SharedFile createFileFromUri(Uri uri) => _IOFile(File.fromUri(uri));

class _IOFile implements SharedFile {
  final File _file;
  String _name;

  _IOFile(this._file) : assert(_file != null);

  @override
  String get mimeType => mime(name.toLowerCase());

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
