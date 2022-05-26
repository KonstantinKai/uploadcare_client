import 'package:test/test.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  late ApiVideoEncoding api;

  setUpAll(() {
    api = ApiVideoEncoding(
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
      'video-id-1': [
        VideoFormatTransformation(),
        VideoThumbsGenerateTransformation(),
      ],
      'video-id-2': [
        VideoResizeTransformation(Dimensions(512, 384)),
      ],
    });

    expect(
        paths,
        containsAll([
          'video-id-1/video/-/format/mp4/-/thumbs~1/',
          'video-id-2/video/-/resize/512x384/'
        ]));
  });

  test('Create converting job', () async {
    final result = await api.process({
      'video-id-1': [
        VideoFormatTransformation(),
        VideoThumbsGenerateTransformation(),
      ]
    });

    expect(result, TypeMatcher<ConvertEntity<VideoEncodingResultEntity>>());
  });

  test('Converting job status', () {
    final status = api.statusAsStream(123456789,
        checkInterval: Duration(milliseconds: 10));

    expect(
        status,
        emitsInOrder([
          isA<ConvertJobEntity<VideoEncodingResultEntity>>(),
          isA<ConvertJobEntity<VideoEncodingResultEntity>>(),
          isA<ConvertJobEntity<VideoEncodingResultEntity>>(),
          emitsDone,
        ]));
  });
}
