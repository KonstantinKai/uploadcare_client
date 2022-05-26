import 'uc_file.dart';

UCFile createFile(Object file) => throw UnsupportedError(
    'Cannot create a file without dart:html or dart:io.');

UCFile createFileFromUri(Uri uri) => throw UnsupportedError(
    'Cannot create a file from uri without dart:html or dart:io.');
