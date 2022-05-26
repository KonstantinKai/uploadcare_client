import 'dart:io';
import 'package:mime/mime.dart';
import 'uc_file.dart';

UCFile createFile(Object file) => _IOFile(file as File);

UCFile createFileFromUri(Uri uri) => _IOFile(File.fromUri(uri));

class _IOFile implements UCFile {
  final File _file;
  final String _name;

  _IOFile(this._file) : _name = Uri.parse(_file.path).pathSegments.last;

  @override
  String get mimeType => lookupMimeType(name.toLowerCase()) ?? '';

  @override
  String get name => _name;

  @override
  Future<int> length() => _file.length();

  @override
  Stream<List<int>> openRead([
    int? start,
    int? end,
  ]) =>
      _file.openRead(start, end);
}
