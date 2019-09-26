import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';
import 'package:flutter_uploadcare_client/src/entities/group.dart';
import 'package:flutter_uploadcare_client/flutter_uploadcare_client.dart';

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

  test('Create group', () async {
    final response = await client.groups.create({
      'aca02b0a-2db1-42a3-ae53-a290d6b6b0a0': [],
    });
    expect(response, TypeMatcher<GroupInfoEntity>());
  });

  test('Get group list', () async {
    final response = await client.groups.list();
    expect(response, TypeMatcher<ListEntity<GroupInfoEntity>>());
  });
}
