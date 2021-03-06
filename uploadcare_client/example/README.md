## How to use library

```dart
import 'package:uploadcare_client/uploadcare_client.dart';
```

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