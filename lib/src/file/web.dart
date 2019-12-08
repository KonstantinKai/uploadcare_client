import 'dart:async';
import 'dart:html';

import 'package:uploadcare_client/src/file/file.dart';

SharedFile createFile(dynamic file) => _WebFile(file as File);

SharedFile createFileFromUri(Uri uri) =>
    throw UnsupportedError('Cannot create a file from uri with dart:html');

class _WebFile implements SharedFile {
  final File _file;

  _WebFile(this._file) : assert(_file != null);

  @override
  String get mimeType => _file.type;

  @override
  String get name => _file.name;

  @override
  Future<int> length() => Future.value(_file.size);

  @override
  Stream<List<int>> openRead([int start, int end]) {
    final controller = StreamController<List<int>>();
    final reader = FileReader();

    reader.onLoadEnd.listen((data) {
      controller.add(reader.result);
      controller.close();
    });

    Blob blob = _file;

    if (start != null && end != null)
      blob = _file.slice(start, end, mimeType);
    else if (start != null) blob = _file.slice(start);

    reader.readAsArrayBuffer(blob);

    return controller.stream;
  }
}
