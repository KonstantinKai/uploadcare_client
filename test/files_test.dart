import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';
import 'package:uploadcare_client/src/entities/file_info.dart';
import 'package:uploadcare_client/src/entities/list.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  UploadcareClient client;

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
  });

  test('Get files', () async {
    final response = await client.files.list();
    expect(response, TypeMatcher<ListEntity<FileInfoEntity>>());
  });

  test('Get file info', () async {
    final fileId = await client.upload.base(File(env['UPLOAD_BASE']));
    final file = await client.files.file(fileId);

    expect(file, TypeMatcher<FileInfoEntity>());
  });
}
