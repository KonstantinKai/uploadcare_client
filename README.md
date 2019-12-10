![alt flutter uploadcare client](https://drive.google.com/uc?export=download&id=1aUeEPWSFwzPVeMn6NGRf7B4x-bPKOkHM)

## Flutter Uploadcare Client

### Breaking changes
The Flutter team made a breaking change with the ImageProvider in Flutter `1.10.15`. Also, the Flutter team doesn't recommend use flutter_web in `1.9`, that why I specify flutter SDK constraints for the `2.0.0` version. This version added the ability to upload files in flutter_web environment.

If you have the following error, please upgrade to `2.0.0`
```sh
The method 'UploadcareImageProvider.load' has fewer positional arguments than those of overridden method 'ImageProvider.load'
```

### Limitations
* It's impossible to use `AuthSchemeRegular` auth scheme in `flutter_web` with fetch API because `Date` request header is forbidden for XMLRequest https://fetch.spec.whatwg.org/#forbidden-header-name.
* It's impossible to run the upload process in the separate isolate.

## Introduction
Uploadcare is a complete file handling platform that helps you ship products faster and focus on your business goals, not files. With Uploadcare, you can build an infrastructure, optimize content, conversions, load times, traffic, and user experience. [Read more...](https://uploadcare.com/docs/)

#### Implemented features:
- authorization
  - simple, [read more](https://uploadcare.com/docs/api_reference/rest/requests_auth/#auth-simple)
  - regular, [read more](https://uploadcare.com/docs/api_reference/rest/requests_auth/#auth-uploadcare)
- [upload](#example), [read more](https://uploadcare.com/docs/api_reference/upload/)
  - base
  - multipart
  - from url
  - signed uploads, [read more](https://uploadcare.com/docs/api_reference/upload/signed_uploads/)
  - [cancellable upload](#cancellation)
  - [upload in isolate](#upload-in-isolates)
- files API, [read more](https://uploadcare.com/docs/api_reference/rest/accessing_files/)
  - get one file
  - get list of files
  - remove multiple files
  - store multiple files
  - [gif to video](#gif-to-video), [read more](https://uploadcare.com/docs/image_transformations/gif2video/)
  - [face recognition](#face-recognition), [read more](https://uploadcare.com/docs/image_transformations/face_recognition/)
- groups API
  - get one group
  - get list of groups
  - create group
  - store all files in group
- video encoding, [read more](https://uploadcare.com/docs/video_encoding/#process-operations)
  - [create processing tasks](#video-encoding)
  - retrieve processing status
- CDN API
  - image transformations, [read more](https://uploadcare.com/docs/api_reference/cdn/)
  - group transformations, [read more](https://uploadcare.com/docs/delivery/group_api/)
  - video transformations
- Flutter (mobile/web)
  - [UploadcareImageProvider](#using-with-widgets) (**since `2.0.0`**)

#### Roadmap:
- document conversion

![alt flutter uploadcare example](https://drive.google.com/uc?export=download&id=1nj2rLUgbanzq-4CfJiRSkvMA_qOi10-s)

![alt flutter uploadcare face rocognition example](https://drive.google.com/uc?export=download&id=1HPIyuq6G_1MI3XN1ll0fHgGnk-J4bSi1)

![alt flutter uploadcare web upload video](https://drive.google.com/uc?export=download&id=188FQUmaf5u18j17iMaMNJ-8CeI2-6m_H)

![alt flutter uploadcare web upload image](https://drive.google.com/uc?export=download&id=1uSYJ4MdBtVmvM4iWsOmyS7mFvyv7818L)

## Example:
**Note:** you can omit `privateKey`, but in this case only Upload API will be available. (CDN API also will be available).

How to use library:
```dart
// create client with simple auth scheme
final client = UploadcareClient.withSimpleAuth(
  publicKey: 'UPLOADCARE_PUBLIC_KEY',
  privateKey: 'UPLOADCARE_PRIVATE_KEY',
  apiVersion: 'v0.5',
);
// or create client with reqular auth scheme
final client = UploadcareClient.withRegularAuth(
  publicKey: 'UPLOADCARE_PUBLIC_KEY',
  privateKey: 'UPLOADCARE_PRIVATE_KEY',
  apiVersion: 'v0.5',
);
// or more flexible
final client = UploadcareClient(
  options: ClientOptions(
    authorizationScheme: AuthSchemeRegular(
      apiVersion: 'v0.5',
      publicKey: 'UPLOADCARE_PUBLIC_KEY',
      privateKey: 'UPLOADCARE_PRIVATE_KEY',
    ),
    // rest options...
  ),
);
```
`UploadcareClient` has at the moment 4 API section
```dart
final ApiUpload upload;
final ApiFiles files;
final ApiVideoEncoding videoEncoding;
final ApiGroups groups;
```
You can use each api section separately, for example:
```dart
final options = ClientOptions(
  authorizationScheme: AuthSchemeRegular(
    apiVersion: 'v0.5',
    publicKey: 'UPLOADCARE_PUBLIC_KEY',
    privateKey: 'UPLOADCARE_PRIVATE_KEY',
  )
);

final upload = ApiUpload(options: options);
final fileId = await upload.base(SharedFile(File('...some/file')));
// ...etc.
```
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

## Cancellation
You can cancel the upload process by using `CancelToken`, each method from the upload section (`auto, base, multipart`) accepts `cancelToken` property, which you can use to cancel the upload process. This feature works only with files upload because Uploadcare isn't supporting interrupt upload by URL

```dart
...

final cancelToken = CancelToken();

...

try {
  final fileId = await client.upload.multipart(
    SharedFile(File('/some/file')),
    cancelToken: cancelToken,
  );
} on CancelUploadException catch (e) {
  // cancelled
}

...

// somewhere in code
cancelToken.cancel();

```
## Face Recognition
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

## Gif to video
```dart
final file = CdnFile('gif-id-1')
  ..transform(GifToVideoTransformation([
    VideoFormatTransformation(VideoFormatTValue.Mp4),
    QualityTransformation(QualityTValue.Best),
  ]));

...

VideoPlayerController.network(file.url);
```

## Video encoding 
```dart
...

final videoEncoding = ApiVideoEncoding(options);

final VideoEncodingConvertEntity result = await videoEncoding.process({
  'video-id-1': [
    CutTransformation(
      const const Duration(seconds: 10),
      length: const Duration(
        seconds: 30,
      ),
    )
  ],
  'video-id-2': [
    VideoResizeTransformation(const Size(512, 384)),
    VideoThumbsGenerateTransformation(10),
  ],
});

final Stream<VideoEncodingJobEntity> processingStream = videoEncoding.statusAsStream(
  result.results.first.token,
  checkInterval: const Duration(seconds: 2),
)..listen((VideoEncodingJobEntity status) {
  // do something
})
```

## Upload in isolates
```dart
final client = UploadcareClient(
  options: ClientOptions(
    // setup max concurrent running isolates
    maxIsolatePoolSize: 3,
    authorizationScheme: AuthSchemeSimple(
      apiVersion: 'v0.5',
      publicKey: env['UPLOADCARE_PUBLIC_KEY'],
    ),
  ),
);

final id = await client.upload.auto(
  SharedFile(File('/some/file')),
  runInIsolate: true,
);
```