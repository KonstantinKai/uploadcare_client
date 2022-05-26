import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late ApiDocumentConverting api;

  setUpAll(() {
    api = ApiDocumentConverting(
      options: ClientOptions(
        apiUrl: 'http://localhost:7070',
        authorizationScheme: AuthSchemeRegular(
          apiVersion: 'v0.7',
          publicKey: 'public_key',
          privateKey: 'private_key',
        ),
      ),
    );
  });

  test('transformToPaths', () {
    final paths = api.transformToPaths({
      'document-id-1': [
        DocumentFormatTransformation(DucumentOutFormatTValue.PDF),
      ],
      'document-id-2': [
        DocumentFormatTransformation(DucumentOutFormatTValue.PNG, page: 10),
      ],
    });

    expect(
        paths,
        containsAll([
          'document-id-1/document/-/format/pdf/',
          'document-id-2/document/-/format/png/-/page/10/'
        ]));
  });

  test('Create converting job', () async {
    final result = await api.process({
      'document-id-1': [
        DocumentFormatTransformation(DucumentOutFormatTValue.PDF),
      ]
    });

    expect(
        result, TypeMatcher<ConvertEntity<DocumentConvertingResultEntity>>());
  });

  test('Converting job status', () {
    final status = api.statusAsStream(123456789,
        checkInterval: Duration(milliseconds: 10));

    expect(
        status,
        emitsInOrder([
          isA<ConvertJobEntity<DocumentConvertingResultEntity>>(),
          isA<ConvertJobEntity<DocumentConvertingResultEntity>>(),
          isA<ConvertJobEntity<DocumentConvertingResultEntity>>(),
          emitsDone,
        ]));
  });
}
