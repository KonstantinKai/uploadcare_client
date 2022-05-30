import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late ApiProject api1;
  late ApiProject api2;

  setUpAll(() {
    api1 = ApiProject(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        authorizationScheme: AuthSchemeSimple(
          apiVersion: 'v0.5',
          publicKey: 'pub_key1',
          privateKey: 'priv_key1',
        ),
      ),
    );
    api2 = ApiProject(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        authorizationScheme: AuthSchemeSimple(
          apiVersion: 'v0.5',
          publicKey: 'pub_key2',
          privateKey: 'priv_key2',
        ),
      ),
    );
  });

  test('Get project info #1', () async {
    final result = await api1.info();

    expect(result, isA<ProjectEntity>());
    expect(result.name, isA<String>());
    expect(result.autoStoreEnabled, isTrue);
    expect(result.collaborators.isNotEmpty, isTrue);
  });

  test('Get project info #2', () async {
    final result = await api2.info();

    expect(result, isA<ProjectEntity>());
    expect(result.name, isA<String>());
    expect(result.autoStoreEnabled, isFalse);
    expect(result.collaborators.isEmpty, isTrue);
  });
}
