import 'package:test/test.dart';
import 'package:uploadcare_client/src/measures.dart';
import 'package:uploadcare_client/src/transformations/base.dart';
import 'package:uploadcare_client/src/transformations/common.dart';
import 'package:uploadcare_client/src/transformations/group.dart';
import 'package:uploadcare_client/src/transformations/image.dart';
import 'package:uploadcare_client/src/transformations/video.dart';

void testDelimiter(Transformation transform, [String expected = '-/']) =>
    expect(transform.delimiter, equals(expected));

void main() {
  group('Common', () {
    test('QualityTransformation', () {
      testDelimiter(QualityTransformation());
      expect(QualityTransformation().toString(), equals('quality/normal'));
      expect(QualityTransformation(QualityTValue.Lightest).toString(),
          equals('quality/lightest'));
      expect(QualityTransformation(QualityTValue.Lighter).toString(),
          equals('quality/lighter'));
      expect(QualityTransformation(QualityTValue.Better).toString(),
          equals('quality/better'));
      expect(QualityTransformation(QualityTValue.Best).toString(),
          equals('quality/best'));
      expect(QualityTransformation(QualityTValue.Smart).toString(),
          equals('quality/smart'));
    });

    test('ResizeTransformation', () {
      testDelimiter(ResizeTransformation(Dimensions.zero));
      expect(ResizeTransformation(Dimensions.zero).toString(),
          equals('resize/0x0'));
      expect(ResizeTransformation(Dimensions.fromWidth(100)).toString(),
          equals('resize/100x'));
      expect(ResizeTransformation(Dimensions.fromHeight(100)).toString(),
          equals('resize/x100'));

      expect(() => ResizeTransformation(Dimensions.fromWidth(5001)),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ResizeTransformation(Dimensions.fromHeight(5001)),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ResizeTransformation(Dimensions(5001, 5001)),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('GifToVideoTransformation', () {
      testDelimiter(GifToVideoTransformation(), '');
      expect(
          GifToVideoTransformation([
            VideoFormatTransformation(VideoFormatTValue.Mp4),
            QualityTransformation(QualityTValue.Best),
          ]).toString(),
          equals('gif2video/-/format/mp4/-/quality/best'));
      expect(
          () => GifToVideoTransformation([
                CutTransformation(const Duration(seconds: 1), end: true),
              ]),
          throwsA(TypeMatcher<AssertionError>()));
    });
  });

  group('Group', () {
    test('ArchiveTransformation', () {
      testDelimiter(ArchiveTransformation(ArchiveTValue.Zip), '');
      expect(ArchiveTransformation(ArchiveTValue.Zip).toString(),
          equals('archive/zip'));
      expect(ArchiveTransformation(ArchiveTValue.Tar).toString(),
          equals('archive/tar'));
      expect(
          ArchiveTransformation(ArchiveTValue.Zip, 'filename.zip').toString(),
          equals('archive/zip/filename.zip'));
    });
  });

  group('Image', () {
    test('ImageFormatTransformation', () {
      testDelimiter(ImageFormatTransformation(ImageFormatTValue.Auto));
      expect(ImageFormatTransformation(ImageFormatTValue.Auto).toString(),
          equals('format/auto'));
      expect(ImageFormatTransformation(ImageFormatTValue.Jpeg).toString(),
          equals('format/jpeg'));
      expect(ImageFormatTransformation(ImageFormatTValue.Png).toString(),
          equals('format/png'));
      expect(ImageFormatTransformation(ImageFormatTValue.Webp).toString(),
          equals('format/webp'));
    });

    test('ProgressiveTransformation', () {
      testDelimiter(ProgressiveTransformation());
      expect(ProgressiveTransformation().toString(), equals('progressive/no'));
      expect(ProgressiveTransformation(true).toString(),
          equals('progressive/yes'));
    });

    test('AutoRotateTransformation', () {
      testDelimiter(AutoRotateTransformation());
      expect(AutoRotateTransformation().toString(), equals('autorotate/yes'));
      expect(
          AutoRotateTransformation(false).toString(), equals('autorotate/no'));
    });

    test('RotateTransformation', () {
      testDelimiter(RotateTransformation(0));
      expect(RotateTransformation(45).toString(), equals('rotate/45'));
      expect(RotateTransformation(-45).toString(), equals('rotate/-45'));
      expect(() => RotateTransformation(380),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('FlipTransformation', () {
      testDelimiter(FlipTransformation());
      expect(FlipTransformation().toString(), equals('flip'));
    });

    test('MirrorTransformation', () {
      testDelimiter(MirrorTransformation());
      expect(MirrorTransformation().toString(), equals('mirror'));
    });

    test('GrayscaleTransformation', () {
      testDelimiter(GrayscaleTransformation());
      expect(GrayscaleTransformation().toString(), equals('grayscale'));
    });

    test('InvertTransformation', () {
      testDelimiter(InvertTransformation());
      expect(InvertTransformation().toString(), equals('invert'));
    });

    test('EnhanceTransformation', () {
      testDelimiter(EnhanceTransformation());
      expect(EnhanceTransformation().toString(), equals('enhance/50'));
      expect(() => EnhanceTransformation(101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => EnhanceTransformation(-1),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('SharpTransformation', () {
      testDelimiter(SharpTransformation());
      expect(SharpTransformation().toString(), equals('sharp/5'));
      expect(() => SharpTransformation(21),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => SharpTransformation(-1),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('BlurTransformation', () {
      testDelimiter(BlurTransformation());
      expect(BlurTransformation().toString(), equals('blur/10'));
      expect(() => BlurTransformation(5001),
          throwsA(TypeMatcher<AssertionError>()));
      expect(
          () => BlurTransformation(-1), throwsA(TypeMatcher<AssertionError>()));
    });

    test('MaxIccSizeTransformation', () {
      testDelimiter(MaxIccSizeTransformation());
      expect(MaxIccSizeTransformation().toString(), equals('max_icc_size/10'));
      expect(() => MaxIccSizeTransformation(-1),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('StretchTransformation', () {
      testDelimiter(StretchTransformation());
      expect(StretchTransformation().toString(), equals('stretch/on'));
      expect(StretchTransformation(StretchTValue.Fill).toString(),
          equals('stretch/fill'));
      expect(StretchTransformation(StretchTValue.Off).toString(),
          equals('stretch/off'));
    });

    test('SetFillTransformation', () {
      testDelimiter(SetFillTransformation());
      expect(SetFillTransformation().toString(), equals('setfill/ffffff'));
    });

    test('ScaleCropTransformation', () {
      testDelimiter(ScaleCropTransformation(Dimensions.zero));
      expect(ScaleCropTransformation(Dimensions.zero).toString(),
          equals('scale_crop/0x0'));
      expect(ScaleCropTransformation(Dimensions.zero, center: true).toString(),
          equals('scale_crop/0x0/center'));
      expect(
          ScaleCropTransformation(
            Dimensions.zero,
            offset: Offsets.zero,
          ).toString(),
          equals('scale_crop/0x0/0,0'));
      expect(
          ScaleCropTransformation(
            Dimensions.zero,
            type: ScaleCropTypeTValue.Smart,
          ).toString(),
          equals('scale_crop/0x0/smart'));
      expect(
          ScaleCropTransformation(
            Dimensions.zero,
            type: ScaleCropTypeTValue.Smart,
            offset: Offsets.zero,
          ).toString(),
          equals('scale_crop/0x0/smart/0,0'));
      expect(
          ScaleCropTransformation(
            Dimensions.zero,
            type: ScaleCropTypeTValue.SmartFacesObjects,
            center: true,
          ).toString(),
          equals('scale_crop/0x0/smart_faces_objects/center'));
    });

    test('PreviewTransformation', () {
      testDelimiter(PreviewTransformation());
      expect(PreviewTransformation().toString(), equals('preview/2048x2048'));
    });

    test('CropTransformation', () {
      testDelimiter(CropTransformation(Dimensions.zero));
      expect(
          CropTransformation(Dimensions.zero).toString(), equals('crop/0x0'));
      expect(
          CropTransformation(Dimensions.zero, Coordinates(Offsets(10, 10)))
              .toString(),
          equals('crop/0x0/10,10'));
      expect(CropTransformation(Dimensions.zero, Coordinates.center).toString(),
          equals('crop/0x0/center'));
    });

    test('ImageResizeTransformation', () {
      testDelimiter(ImageResizeTransformation(Dimensions.zero));
      expect(ImageResizeTransformation(Dimensions.zero).toString(),
          equals('resize/0x0'));
    });

    test('OverlayTransformation', () {
      testDelimiter(OverlayTransformation('image-id-2'));
      expect(OverlayTransformation('image-id-2').toString(),
          equals('overlay/image-id-2'));
      expect(
          OverlayTransformation(
            'image-id-2',
            dimensions: Dimensions(40, 30, units: MeasureUnits.Percent),
            coordinates: Coordinates.center,
            opacity: 40,
          ).toString(),
          equals('overlay/image-id-2/40px30p/center/40p'));
      expect(
          () => OverlayTransformation(
                'image-id-2',
                coordinates: Coordinates.center,
              ),
          throwsA(TypeMatcher<AssertionError>()));
      expect(
          () => OverlayTransformation(
                'image-id-2',
                dimensions: Dimensions(40, 30, units: MeasureUnits.Percent),
                opacity: 40,
              ),
          throwsA(TypeMatcher<AssertionError>()));
      expect(
          OverlayTransformation(
            'self',
            dimensions: Dimensions(40, 30, units: MeasureUnits.Percent),
            coordinates: Coordinates.center,
            opacity: 40,
          ).toString(),
          equals('overlay/self/40px30p/center/40p'));
    });

    test('BlurRegionTransformation', () {
      testDelimiter(BlurRegionTransformation(type: BlurRegionTValue.Faces));
      expect(() => BlurRegionTransformation(),
          throwsA(TypeMatcher<AssertionError>()));
      expect(
          BlurRegionTransformation(
                  dimensions: Dimensions(10, 20), coordinates: Offsets(10, 10))
              .toString(),
          equals('blur_region/10x20/10,10'));
      expect(
          BlurRegionTransformation(
                  dimensions: Dimensions(10, 20),
                  coordinates: Offsets(10, 10),
                  radius: 20)
              .toString(),
          equals('blur_region/10x20/10,10/20'));
      expect(
          BlurRegionTransformation(
                  dimensions: Dimensions(10, 20, units: MeasureUnits.Percent),
                  coordinates: Offsets(10, 10, units: MeasureUnits.Percent))
              .toString(),
          equals('blur_region/10px20p/10p,10p'));
      expect(BlurRegionTransformation(type: BlurRegionTValue.Faces).toString(),
          equals('blur_region/faces'));
      expect(
          BlurRegionTransformation(type: BlurRegionTValue.Faces, radius: 20)
              .toString(),
          equals('blur_region/faces/20'));
    });

    test('UnsharpMaskingTransformation', () {
      testDelimiter(UnsharpMaskingTransformation());
      expect(() => UnsharpMaskingTransformation(-201),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => UnsharpMaskingTransformation(101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(UnsharpMaskingTransformation().toString(), equals('blur/10/100'));
    });

    test('FilterTransformation', () {
      testDelimiter(FilterTransformation(FilterTValue.Adaris));
      expect(() => FilterTransformation(FilterTValue.Adaris, -101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => FilterTransformation(FilterTValue.Adaris, 201),
          throwsA(TypeMatcher<AssertionError>()));

      // ignore: avoid_function_literals_in_foreach_calls
      FilterTValue.values.forEach((value) {
        final transformed = value.toString().split('.').last.toLowerCase();
        expect(FilterTransformation(value).toString(),
            equals('filter/$transformed/100'));
      });
    });

    test('ZoomObjectTransformation', () {
      testDelimiter(ZoomObjectTransformation(0));
      expect(() => ZoomObjectTransformation(-1),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ZoomObjectTransformation(101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(
          ZoomObjectTransformation(10).toString(), equals('zoom_objects/10'));
    });

    test('ColorBrightnessTransformation', () {
      testDelimiter(ColorBrightnessTransformation(10));
      expect(() => ColorBrightnessTransformation(-101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ColorBrightnessTransformation(101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(ColorBrightnessTransformation(10).toString(),
          equals('brightness/10'));
    });

    test('ColorExposureTransformation', () {
      testDelimiter(ColorExposureTransformation(10));
      expect(() => ColorExposureTransformation(-501),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ColorExposureTransformation(501),
          throwsA(TypeMatcher<AssertionError>()));
      expect(ColorExposureTransformation(10).toString(), equals('exposure/10'));
    });

    test('ColorGammaTransformation', () {
      testDelimiter(ColorGammaTransformation(10));
      expect(() => ColorGammaTransformation(-1),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ColorGammaTransformation(1001),
          throwsA(TypeMatcher<AssertionError>()));
      expect(ColorGammaTransformation(10).toString(), equals('gamma/10'));
    });

    test('ColorContrastTransformation', () {
      testDelimiter(ColorContrastTransformation(10));
      expect(() => ColorContrastTransformation(-101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ColorContrastTransformation(501),
          throwsA(TypeMatcher<AssertionError>()));
      expect(ColorContrastTransformation(10).toString(), equals('contrast/10'));
    });

    test('ColorSaturationTransformation', () {
      testDelimiter(ColorSaturationTransformation(10));
      expect(() => ColorSaturationTransformation(-101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ColorSaturationTransformation(501),
          throwsA(TypeMatcher<AssertionError>()));
      expect(ColorSaturationTransformation(10).toString(),
          equals('saturation/10'));
    });

    test('ColorVibranceTransformation', () {
      testDelimiter(ColorVibranceTransformation(10));
      expect(() => ColorVibranceTransformation(-101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ColorVibranceTransformation(501),
          throwsA(TypeMatcher<AssertionError>()));
      expect(ColorVibranceTransformation(10).toString(), equals('vibrance/10'));
    });

    test('ColorWarmthTransformation', () {
      testDelimiter(ColorWarmthTransformation(10));
      expect(() => ColorWarmthTransformation(-101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => ColorWarmthTransformation(101),
          throwsA(TypeMatcher<AssertionError>()));
      expect(ColorWarmthTransformation(10).toString(), equals('warmth/10'));
    });

    test('SrgbTransformation', () {
      testDelimiter(SrgbTransformation(SrgbTValue.Fast));
      expect(
          SrgbTransformation(SrgbTValue.Fast).toString(), equals('srgb/fast'));
      expect(SrgbTransformation(SrgbTValue.Icc).toString(), equals('srgb/icc'));
      expect(SrgbTransformation(SrgbTValue.KeepProfile).toString(),
          equals('srgb/keep_profile'));
    });

    test('InlineTransformation', () {
      testDelimiter(InlineTransformation(true));
      expect(InlineTransformation(true).toString(), equals('inline/yes'));
      expect(InlineTransformation(false).toString(), equals('inline/no'));
    });
  });

  group('Video', () {
    test('VideoFormatTransformation', () {
      testDelimiter(VideoFormatTransformation());
      expect(VideoFormatTransformation().toString(), equals('format/mp4'));
      expect(VideoFormatTransformation(VideoFormatTValue.Ogg).toString(),
          equals('format/ogg'));
      expect(VideoFormatTransformation(VideoFormatTValue.Webm).toString(),
          equals('format/webm'));
    });

    test('VideoResizeTransformation', () {
      testDelimiter(VideoResizeTransformation(Dimensions(512, 384)));
      expect(VideoResizeTransformation(Dimensions(512, 384)).toString(),
          equals('resize/512x384'));
      expect(
          VideoResizeTransformation(
                  Dimensions(512, 384), VideoResizeTValue.AddPadding)
              .toString(),
          equals('resize/512x384/add_padding'));
      expect(
          VideoResizeTransformation(
                  Dimensions(512, 384), VideoResizeTValue.BreakRatio)
              .toString(),
          equals('resize/512x384/break_ratio'));
      expect(
          VideoResizeTransformation(
                  Dimensions(512, 384), VideoResizeTValue.PreserveRatio)
              .toString(),
          equals('resize/512x384/preserve_ratio'));
      expect(
          VideoResizeTransformation(
                  Dimensions(512, 384), VideoResizeTValue.ScaleCrop)
              .toString(),
          equals('resize/512x384/scale_crop'));
      expect(() => VideoResizeTransformation(Dimensions(100, 310)),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('CutTransformation', () {
      testDelimiter(CutTransformation(const Duration(seconds: 1)));
      expect(CutTransformation(const Duration(seconds: 1)).toString(),
          equals('cut/000:00:01/end'));
      expect(
          CutTransformation(const Duration(seconds: 1),
                  length: const Duration(seconds: 5))
              .toString(),
          equals('cut/000:00:01/000:00:05'));
      expect(() => CutTransformation(const Duration(seconds: 1), end: null),
          throwsA(TypeMatcher<AssertionError>()));
    });

    test('VideoThumbsGenerateTransformation', () {
      testDelimiter(VideoThumbsGenerateTransformation());
      expect(
          VideoThumbsGenerateTransformation().toString(), equals('thumbs~1'));
      expect(VideoThumbsGenerateTransformation(30).toString(),
          equals('thumbs~30'));
      expect(() => VideoThumbsGenerateTransformation(0),
          throwsA(TypeMatcher<AssertionError>()));
      expect(() => VideoThumbsGenerateTransformation(51),
          throwsA(TypeMatcher<AssertionError>()));
    });
  });
}
