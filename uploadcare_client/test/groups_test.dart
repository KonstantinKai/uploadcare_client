import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late ApiGroups api;

  setUpAll(() {
    api = ApiGroups(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        uploadUrl: 'http://localhost:7070/upload',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.7',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );
  });

  test('Get list of groups', () async {
    final list = await api.list();

    expect(list, TypeMatcher<ListEntity<GroupInfoEntity>>());
  });

  test('Create group', () async {
    final group = await api.create({
      'dd43982b-5447-44b2-86f6-1c3b52afa0ff': [
        RotateTransformation(90),
        FlipTransformation(),
      ]
    });

    expect(group, TypeMatcher<GroupInfoEntity>());
  });

  test('Get group info', () async {
    final group = await api.group('dd43982b-5447-44b2-86f6-1c3b52afa0ff~1');

    expect(group, TypeMatcher<GroupInfoEntity>());
  });

  test('Delete group', () async {
    await api.delete('dd43982b-5447-44b2-86f6-1c3b52afa0ff~1');
  });
}
