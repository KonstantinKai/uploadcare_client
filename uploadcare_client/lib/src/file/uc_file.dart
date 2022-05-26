import 'stub.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'io.dart';

/// Base class which describes cross-platform file implementation
abstract class UCFile {
  /// Filename
  String get name;

  /// File myme type
  String get mimeType;

  /// Create cross-platform file
  factory UCFile(Object file) => createFile(file);

  /// Trying to resolve file from [Uri]
  /// Not working with `web`
  factory UCFile.fromUri(Uri uri) => createFileFromUri(uri);

  /// Retrieve file size in bytes
  Future<int> length();

  /// Create a new independent Stream for the contents of this file.
  Stream<List<int>> openRead([
    int start,
    int end,
  ]);
}
