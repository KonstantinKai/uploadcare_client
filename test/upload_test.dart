import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  UploadcareClient client;
  UploadcareClient clientSigned;
  final List<String> ids = [];
  final List<String> signedIds = [];

  setUpAll(() {
    load();

    client = UploadcareClient(
      options: ClientOptions(
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.5',
          publicKey: env['UPLOADCARE_PUBLIC_KEY'],
          privateKey: env['UPLOADCARE_PRIVATE_KEY'],
        ),
      ),
    );

    clientSigned = UploadcareClient(
      options: ClientOptions(
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.5',
          publicKey: env['UPLOADCARE_PUBLIC_KEY_SIGNED'],
          privateKey: env['UPLOADCARE_PRIVATE_KEY_SIGNED'],
        ),
        useSignedUploads: true,
      ),
    );
  });

  tearDownAll(() async {
    if (ids.isNotEmpty) await client.files.remove(ids);
    if (signedIds.isNotEmpty) await clientSigned.files.remove(signedIds);
  });

  test('Simple base upload', () async {
    final id = await client.upload.base(
      File(env['UPLOAD_BASE']),
      storeMode: false,
    );

    expect(id, isA<String>());

    ids.add(id);
  });

  test('Simple multipart upload', () async {
    final id = await client.upload.multipart(
      File(env['UPLOAD_MULTIPART']),
      storeMode: false,
    );

    expect(id, isA<String>());

    ids.add(id);
  });

  test('Simple url upload', () async {
    final id = await client.upload.fromUrl(
      env['UPLOAD_URL'],
      storeMode: false,
    );

    expect(id, isA<String>());

    ids.add(id);
  });

  test('Signed base upload', () async {
    final id = await clientSigned.upload.base(
      File(env['UPLOAD_BASE']),
      storeMode: false,
    );

    expect(id, isA<String>());

    signedIds.add(id);
  });

  test('Signed multipart upload', () async {
    final id = await clientSigned.upload.multipart(
      File(env['UPLOAD_MULTIPART']),
      storeMode: false,
    );

    expect(id, isA<String>());

    signedIds.add(id);
  });

  test('Signed url upload', () async {
    final id = await clientSigned.upload.fromUrl(
      env['UPLOAD_URL'],
      storeMode: false,
    );

    expect(id, isA<String>());

    signedIds.add(id);
  });
}
