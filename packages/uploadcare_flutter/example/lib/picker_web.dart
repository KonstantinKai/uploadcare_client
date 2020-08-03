import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

Future<List<SharedFile>> pickFiles(BuildContext context) async {
  final completer = Completer<List<SharedFile>>();
  final uploadInput = InputElement()..type = 'file';

  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;

    completer.complete(
      files.isNotEmpty ? [SharedFile(files.first)] : const [],
    );
  });

  return completer.future;
}
