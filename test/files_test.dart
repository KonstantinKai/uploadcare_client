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

  test('Files', () async {
    final response = await client.files.list();
    expect(response, TypeMatcher<ListEntity<FileInfoEntity>>());
  });

  test('File', () async {
    final file =
        await client.files.file('aca02b0a-2db1-42a3-ae53-a290d6b6b0a0');
    expect(file, TypeMatcher<FileInfoEntity>());
  });
}
