import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  test('test #1', () async {
    final client = UploadcareClient(
        options: UploadcareOptions(
      authorizationScheme: UploadcareAuthSchemeSimple(
        apiVersion: 'v0.5',
        publicKey: '9e714b99944330bfc302',
        privateKey: '4808678e0f74604a55ef',
      ),
    ));
    final file = File(
        '/Users/kai/Downloads/PlayBoy [optik.1557]/1920x1200/Playboy (171).jpg');

    await client.upload(file, storeMode: false);
  });

  test('test #2', () async {
    final client = UploadcareClient(
        options: UploadcareOptions(
      authorizationScheme: UploadcareAuthSchemeRegular(
        apiVersion: 'v0.5',
        publicKey: '9e714b99944330bfc302',
        privateKey: '4808678e0f74604a55ef',
      ),
    ));
    final file = File('/Users/kai/Downloads/dismissible_bug.mov');

    print(await client.upload(file, storeMode: false));
  });
}
