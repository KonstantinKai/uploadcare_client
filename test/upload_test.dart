import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  UploadcareClient client;
  final List<String> ids = [];

  setUpAll(() {
    load();

    client = UploadcareClient(
      options: UploadcareOptions(
        authorizationScheme: UploadcareAuthSchemeRegular(
          apiVersion: 'v0.5',
          publicKey: env['UPLOADCARE_PUBLIC_KEY'],
          privateKey: env['UPLOADCARE_PRIVATE_KEY'],
        ),
      ),
    );
  });

  tearDownAll(() async {
    if (ids.isNotEmpty) await client.manager.removeFiles(ids);
  });

  test('Base upload', () async {
    final id = await client.upload.base(
      File(env['UPLOAD_BASE']),
      storeMode: false,
    );

    expect(id, isA<String>());

    ids.add(id);
  });

  test('Multipart upload', () async {
    final id = await client.upload.multipart(
      File(env['UPLOAD_MULTIPART']),
      storeMode: false,
    );

    expect(id, isA<String>());

    ids.add(id);
  });

  test('Url upload', () async {
    final id = await client.upload.fromUrl(
      env['UPLOAD_URL'],
      storeMode: false,
    );

    expect(id, isA<String>());

    ids.add(id);
  });
}
