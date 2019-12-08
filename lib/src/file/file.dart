import 'package:uploadcare_client/src/file/stub.dart'
    if (dart.library.html) 'package:uploadcare_client/src/file/web.dart'
    if (dart.library.io) 'package:uploadcare_client/src/file/io.dart';

abstract class SharedFile {
  String get name;

  String get mimeType;

  factory SharedFile(dynamic file) => createFile(file);

  Future<int> length();

  Stream<List<int>> openRead([
    int start,
    int end,
  ]);
}
