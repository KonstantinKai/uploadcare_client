import 'dart:ui';

import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';
import 'package:uploadcare_client/src/client.dart';
import 'package:uploadcare_client/src/transformations/common.dart';
import 'package:uploadcare_client/src/transformations/image.dart';
import 'package:uploadcare_client/src/transformations/video.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  UploadcareClient client;

  setUpAll(() {
    load();

    client = UploadcareClient(
        options: ClientOptions(
      authorizationScheme: AuthSchemeSimple(
        apiVersion: 'v0.5',
        publicKey: env['UPLOADCARE_PUBLIC_KEY'],
        privateKey: env['UPLOADCARE_PRIVATE_KEY'],
      ),
    ));
  });

  test('test #1', () {
    final image = client.createCdnImage('some-long-id')
      ..transform(ImageResizeTransformation(Size(300, 450)))
      ..transform(QualityTransformation())
      ..transform(ImageFormatTransformation(ImageFormatTValue.Webp))
      ..transform(CropTransformation(Size.square(64), Offset.zero));

    expect(
        image.uri.path,
        equals(
            '/some-long-id/-/resize/300x450/-/quality/normal/-/format/webp/-/crop/64x64/0,0/'));
  });

  test('test #2', () {
    final video = client.createCdnVideo('some-long-id')
      ..transform(VideoResizeTransformation(Size(512, 384)))
      ..transform(CutTransformation(
        const Duration(seconds: 109),
        length: Duration(
          seconds: 30,
        ),
      ));

    expect(
        video.uri.path,
        equals(
            '/some-long-id/video/-/resize/512x384/-/cut/000:01:49/000:00:30/'));
  });
}
