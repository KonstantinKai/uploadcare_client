import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  setUpAll(() {
    load();
  });

  test('test #1', () async {
    final client = UploadcareClient(
        options: UploadcareOptions(
      authorizationScheme: UploadcareAuthSchemeSimple(
        apiVersion: 'v0.5',
        publicKey: env['UPLOADCARE_PUBLIC_KEY'],
        privateKey: env['UPLOADCARE_PRIVATE_KEY'],
      ),
    ));
    final file = File(
        '/Users/kai/Downloads/PlayBoy [optik.1557]/1920x1200/Playboy (173).jpg');

    final id = await client.upload.base(file, storeMode: false);

    expect(id, isA<String>());
  });

  test('test #2', () async {
    final client = UploadcareClient(
        options: UploadcareOptions(
      authorizationScheme: UploadcareAuthSchemeRegular(
        apiVersion: 'v0.5',
        publicKey: env['UPLOADCARE_PUBLIC_KEY'],
        privateKey: env['UPLOADCARE_PRIVATE_KEY'],
      ),
    ));
    final file = File('/Users/kai/Downloads/dismissible_bug.mov');
    // final file = File(
    //     '/Users/kai/Downloads/PlayBoy [optik.1557]/1920x1200/Playboy (178).jpg');

    print(await client.upload.multipart(file, storeMode: false));
  });
}
