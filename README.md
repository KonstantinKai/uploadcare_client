![alt flutter uploadcare client](https://ucarecdn.com/3608b809-bf65-4a90-9b81-37a6983aacdc/logo_small.png)

## Flutter Uploadcare Client

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
- Flutter (mobile)
  - [UploadcareImageProvider](#using-with-widgets)
- **Web**: currently not working on the web, because flutter API (stable/master) differs for `NetworkProvider`, and `File` API from `dart:io` & `dart:html` is not the same.

#### Roadmap:
- document conversion
- write more tests

![alt flutter uploadcare example](https://ucarecdn.com/c1fbe2fc-e48f-417d-b027-e52aa6e13a62/uploadcare_example.gif)

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
final fileId = await upload.base(File('...some/file'));
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
    File('/some/file'),
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

final List<Rect> faces = await files.detectFaces('image-id');
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
