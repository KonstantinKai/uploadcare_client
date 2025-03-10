import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uploadcare_client/uploadcare_client.dart';
import 'package:web/web.dart';

Future<List<UCFile>> pickFiles(BuildContext context) async {
  final completer = Completer<List<UCFile>>();
  final uploadInput = HTMLInputElement()..type = 'file';

  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;

    completer.complete(files != null && files.length > 0
        ? [UCFile(files.item(0) as File)]
        : const []);
  });

  return completer.future;
}
