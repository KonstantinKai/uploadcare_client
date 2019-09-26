## Flutter Uploadcare Client

## Introduction
Uploadcare is a complete file handling platform that helps you ship products faster and focus on your business goals, not files. With Uploadcare, you can build an infrastructure, optimize content, conversions, load times, traffic, and user experience. [Read more...](https://uploadcare.com/docs/)

#### Implemented features:
- athorization
  - simple, [read more](https://uploadcare.com/docs/api_reference/rest/requests_auth/#auth-simple)
  - regular, [read more](https://uploadcare.com/docs/api_reference/rest/requests_auth/#auth-uploadcare)
- upload, [read more](https://uploadcare.com/docs/api_reference/upload/)
  - base
  - multipart
  - from url
  - signed uploads, [read more](https://uploadcare.com/docs/api_reference/upload/signed_uploads/)
- files API, [read more](https://uploadcare.com/docs/api_reference/rest/accessing_files/)
  - get one file
  - get list of files
  - remove multiple files
  - store multiple files
- groups API
  - get one group
  - get list of groups
  - create group
  - store all files in group
- video encoding, [read more](https://uploadcare.com/docs/video_encoding/#process-operations)
  - create processing tasks
  - retrieve processing status
- CDN API
  - image transformations, [read more](https://uploadcare.com/docs/api_reference/cdn/)
  - group transformations, [read more](https://uploadcare.com/docs/delivery/group_api/)
  - video transformations
- Flutter (mobile/web)
  - UploadcareImageProvider

#### Roadmap:
- document conversion
- complete transformations API (overlays, gif to video, .etc)
- write more tests
- more informative example
- test on web
- improve documentation

## Example:
How to use library:
```dart
// create client with simple auth scheme
final client = UploadcareClient.withSimpleAuth(
  publicKey: DotEnv().env['UPLOADCARE_PUBLIC_KEY'],
  privateKey: DotEnv().env['UPLOADCARE_PRIVATE_KEY'],
  apiVersion: 'v0.5',
);
// or create client with reqular auth scheme
final client = UploadcareClient.withRegularAuth(
  publicKey: DotEnv().env['UPLOADCARE_PUBLIC_KEY'],
  privateKey: DotEnv().env['UPLOADCARE_PRIVATE_KEY'],
  apiVersion: 'v0.5',
);
// or more flexible
final client = UploadcareClient(
  options: ClientOptions(
    authorizationScheme: AuthSchemeRegular(
      apiVersion: 'v0.5',
      publicKey: env['UPLOADCARE_PUBLIC_KEY'],
      privateKey: env['UPLOADCARE_PRIVATE_KEY'],
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
    publicKey: env['UPLOADCARE_PUBLIC_KEY'],
    privateKey: env['UPLOADCARE_PRIVATE_KEY'],
  )
);

final upload = ApiUpload(options: options);
final fileId = await upload.base(File('...some/file'));
// ...etc.
```

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

### For more details see an example and read the doc on pub.dev
