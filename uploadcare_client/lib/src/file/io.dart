import 'dart:io';
import 'package:mime/mime.dart';
import 'file.dart';

SharedFile createFile(Object file) => _IOFile(file as File);

SharedFile createFileFromUri(Uri uri) => _IOFile(File.fromUri(uri));

class _IOFile implements SharedFile {
  final File _file;
  late final String? _name;

  _IOFile(this._file);

  @override
  String get mimeType => lookupMimeType(name.toLowerCase()) ?? '';

  @override
  String get name => _name ??= Uri.parse(_file.path).pathSegments.last;

  @override
  Future<int> length() => _file.length();

  @override
  Stream<List<int>> openRead([
    int? start,
    int? end,
  ]) =>
      _file.openRead(start, end);
}
