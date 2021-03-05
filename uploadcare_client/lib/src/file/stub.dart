import 'file.dart';

SharedFile createFile(Object file) => throw UnsupportedError(
    'Cannot create a file without dart:html or dart:io.');

SharedFile createFileFromUri(Uri uri) => throw UnsupportedError(
    'Cannot create a file from uri without dart:html or dart:io.');
