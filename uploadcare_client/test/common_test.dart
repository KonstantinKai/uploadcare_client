import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late UploadcareClient api;

  setUpAll(() {
    api = UploadcareClient(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.5',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );
  });

  test('Ensure right user agent value', () async {
    expect(
        api.files.userAgent,
        matches(RegExp(
            r'UploadcareDart\/\d{1}\.\d{1}\.\d{1}\/public_key\s\(uploadcare_client\)')));
  });
}
