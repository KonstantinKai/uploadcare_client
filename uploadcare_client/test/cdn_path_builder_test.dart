// @dart=2.9

import 'package:test/test.dart';
import 'package:uploadcare_client/src/measures.dart';
import 'package:uploadcare_client/src/transformations/common.dart';
import 'package:uploadcare_client/src/transformations/image.dart';
import 'package:uploadcare_client/src/transformations/path_transformer.dart';
import 'package:uploadcare_client/src/transformations/video.dart';
import 'package:uploadcare_client/uploadcare_client.dart';

void main() {
  test('Image transformations', () {
    final image = CdnImage('some-long-id')
      ..transform(ImageResizeTransformation(Dimensions(300, 450)))
      ..transform(QualityTransformation())
      ..transform(ImageFormatTransformation(ImageFormatTValue.Webp))
      ..transform(CropTransformation(Dimensions.square(64), Offsets.zero));

    expect(
        image.uri.path,
        equals(
            '/some-long-id/-/resize/300x450/-/quality/normal/-/format/webp/-/crop/64x64/0,0/'));
  });

  test('Video transformations', () {
    final video = PathTransformer('some-long-id/video')
      ..transform(VideoResizeTransformation(Dimensions(512, 384)))
      ..transform(VideoThumbsGenerateTransformation(10))
      ..transform(CutTransformation(
        const Duration(seconds: 109),
        length: Duration(
          seconds: 30,
        ),
      ))
      ..sort((a, b) => b is VideoThumbsGenerateTransformation ? -1 : 1);

    expect(
        video.path,
        equals(
            'some-long-id/video/-/cut/000:01:49/000:00:30/-/resize/512x384/-/thumbs~10/'));
  });

  test('CdnImage', () {
    final image = CdnImage('some-long-id');

    expect(image.pathTransformer.path, equals('some-long-id/'));
  });

  test('Get image from CdnGroup', () {
    final group = CdnGroup('some-long-group-id~2');

    expect(group.pathTransformer.path, equals('some-long-group-id~2/'));

    final image = group.getImage(0)
      ..transform(ImageResizeTransformation(Dimensions.square(66)));

    expect(
        image.url,
        equals(
            'https://ucarecdn.com/some-long-group-id~2/nth/0/-/resize/66x66/'));
  });

  test('Group transformations', () {
    final group = CdnGroup('some-long-group-id~2')
      ..transform(ArchiveTransformation(ArchiveTValue.Tar, 'archive.tar'))
      ..transform(ArchiveTransformation(ArchiveTValue.Zip, 'archive.zip'));

    expect(group.pathTransformer.path,
        equals('some-long-group-id~2/archive/tar/archive.tar/'));
  });

  test('Overlay transformations', () {
    final image = CdnImage('image-id-1')
      ..transform(OverlayTransformation(
        'image-id-2',
        dimensions: Dimensions(40, 30),
        coordinates: OverlayCoordinates.center,
        opacity: 40,
      ))
      ..transform(OverlayTransformation(
        'image-id-3',
        dimensions: Dimensions(40, 30),
        coordinates: OverlayCoordinates(const Offsets(40, 90)),
      ));

    expect(
        image.pathTransformer.path,
        equals(
            'image-id-1/-/overlay/image-id-2/40px30p/center/40p/-/overlay/image-id-3/40px30p/40p,90p/'));
  });

  test('GifToVideoTransformation transformation', () {
    final file = CdnFile('gif-id-1')
      ..transform(GifToVideoTransformation([
        VideoFormatTransformation(VideoFormatTValue.Mp4),
        QualityTransformation(QualityTValue.Best),
      ]));

    expect(file.pathTransformer.path,
        equals('gif-id-1/gif2video/-/format/mp4/-/quality/best/'));
  });

  test('CdnFile', () {
    final file = CdnFile('some-long-group-id');

    expect(file.pathTransformer.path, equals('some-long-group-id/'));
  });
}
