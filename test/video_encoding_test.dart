import 'dart:ui';

import 'package:dotenv/dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uploadcare_client/src/transformations/common.dart';
import 'package:uploadcare_client/src/transformations/video.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  UploadcareClient client;

  setUpAll(() {
    load();

    client = UploadcareClient(
        options: UploadcareOptions(
      authorizationScheme: UploadcareAuthSchemeSimple(
        apiVersion: 'v0.5',
        publicKey: env['UPLOADCARE_PUBLIC_KEY'],
        privateKey: env['UPLOADCARE_PRIVATE_KEY'],
      ),
    ));
  });

  test('Test #1', () async {
    client.videoEncoding.process([
      PathTransformer('1/video', operations: [
        VideoResizeTransformation(Size(512, 384)),
      ]),
    ]);
  });
}
