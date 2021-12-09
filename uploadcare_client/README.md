## Uploadcare Client

**!!! IMPORTANT !!!**

Release of `uploadcare_client@^3.0.0` has breaking changes. `Null safety` was introduced. The library has been split into 2 packages, this package can be used in non-flutter environments (web, server, .etc) and for use with flutter please install only `uploadcare_flutter@^1.0.0` which has this package as a dependency, [see](https://pub.dev/packages/uploadcare_flutter).

### Limitations
* It's impossible to use `AuthSchemeRegular` auth scheme on the `web` with fetch API because `Date` request header is forbidden for XMLRequest https://fetch.spec.whatwg.org/#forbidden-header-name.
* It's impossible to run the upload process in the separate isolate on the `web` environment.

## Introduction
Uploadcare is a complete file handling platform that helps you ship products faster and focus on your business goals, not files. With Uploadcare, you can build infrastructure, optimize content, conversions, load times, traffic, and user experience. [Read more...](https://uploadcare.com/docs/)

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
  - [object recognition](#object-recognition), [read more](https://uploadcare.com/docs/intelligence/object-recognition/)
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

#### Roadmap:
- code improuvements
- new transformation api
- document conversion

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
      const Duration(seconds: 10),
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

## Face Recognition 
```dart
final files = ApiFiles(options: options);

final FacesEntity entity = await files.detectFacesWithOriginalImageSize('image-id');
```

## Object Recognition
```dart
final files = ApiFiles(options: options);

// With one file
final FileInfoEntity file = await files.file('image-id', includeRecognitionInfo: true);

// With list of files
final ListEntity<FileInfoEntity> list = await files.list(includeRecognitionInfo: true);
```
