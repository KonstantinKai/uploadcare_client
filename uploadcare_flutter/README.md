![alt flutter uploadcare client](https://drive.google.com/uc?export=download&id=1aUeEPWSFwzPVeMn6NGRf7B4x-bPKOkHM)

## Flutter Uploadcare Client

**!!! IMPORTANT !!!**

If you are using `uploadcare_client@<3.0.0` change the dependency name in your project `pubspec.yaml`
```yaml
# from
dependencies:
  uploadcare_client: '2.x.x'

# to
dependencies:
  uploadcare_flutter: ^1.0.0
```

### Limitations
* It's impossible to use `AuthSchemeRegular` auth scheme in `flutter_web` with fetch API because `Date` request header is forbidden for XMLRequest https://fetch.spec.whatwg.org/#forbidden-header-name.
* It's impossible to run the upload process in the separate isolate in `flutter_web` environment.

## How to use
Please see this package [`uploadcare_client`](https://pub.dev/packages/uploadcare_client) for instructions
This package was introduced a few extensions for base package (`Dimensions`, `Offsets`, `FaceRect`, `FacesEntityExtension`), `UploadcareImageProvider`. If you don't need these features, you can use `uploadcare_client` directly

#### Implemented features:
- Flutter (mobile/web)
  - [UploadcareImageProvider](#using-with-widgets) (**since `2.0.0`**)

![alt flutter uploadcare example](https://drive.google.com/uc?export=download&id=1nj2rLUgbanzq-4CfJiRSkvMA_qOi10-s)

![alt flutter uploadcare face rocognition example](https://drive.google.com/uc?export=download&id=1HPIyuq6G_1MI3XN1ll0fHgGnk-J4bSi1)

![alt flutter uploadcare web upload video](https://drive.google.com/uc?export=download&id=188FQUmaf5u18j17iMaMNJ-8CeI2-6m_H)

![alt flutter uploadcare web upload image](https://drive.google.com/uc?export=download&id=1uSYJ4MdBtVmvM4iWsOmyS7mFvyv7818L)

## Using with widgets
The library provides `UploadcareImageProvider` for more effective use in the widget ecosystem, how to use image provider:
```dart
Image(
  image: UploadcareImageProvider(
    'uploadcare-image-file-uuid',
    // optional, apply transformations to the image
    transformations: [
      BlurTransformation(50),
      GrayscaleTransformation(),
      InvertTransformation(),
      ImageResizeTransformation(Size.square(58))
    ],
    // rest image props...
  ),
)
```

## Face Recognition with flutter
```dart
...
final files = ApiFiles(options: options);

final FacesEntity entity = await files.detectFacesWithOriginalImageSize('image-id');
...
RenderBox renderBox = context.findRenderObject();

return FractionallySizedBox(
  widthFactor: 1,
  heightFactor: 1,
  child: Stack(
    children: <Widget>[
      Positioned.fill(
        child: Image(
          image: UploadcareImageProvider(widget.imageId),
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
        ),
      ),
      ...entity
          .getRelativeFaces(
        Size(
          renderBox.size.width,
          renderBox.size.width /
              entity.originalSize.aspectRatio,
        ),
      )
          .map((face) {
        return Positioned(
          top: face.top,
          left: face.left,
          child: Container(
            width: face.size.width,
            height: face.size.height,
            decoration: BoxDecoration(
              color: Colors.black12,
              border: Border.all(color: Colors.white54, width: 1.0),
            ),
          ),
        );
      }).toList(),
    ],
  ),
);
...
```
