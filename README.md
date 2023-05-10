[![build](https://github.com/KonstantinKai/uploadcare_client/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/KonstantinKai/uploadcare_client/actions/workflows/build.yml)

# Uploadcare client for Dart/Flutter

Uploadcare is a complete file handling platform that helps you ship products faster and focus on your business goals, not files. With Uploadcare, you can build infrastructure, optimize content, conversions, load times, traffic, and user experience. [Read more...](https://uploadcare.com/docs/)

A dart/flutter library for working with Uploadcare REST API. File uploads, media processing, and adaptive delivery for web and mobile.

<a href="https://www.buymeacoffee.com/konstantinkai" target="_blank"><img src="https://github.com/KonstantinKai/uploadcare_client/blob/master/assets/button.png?raw=true" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## Features

- [**Upload**](#upload)
  - [**Base**](#base-upload)
  - [**Multipart**](#chunked-upload)
  - [**From url**](#from-url)
  - [**Auto**](#auto)
  - [**In isolate**](#isolate)
  - [**Progress tracking**](#progress-tracking)
  - [**Cancellable**](#cancellable)
  - [**Signed**](#signed-upload)
- [**Image and file transformations**](#image-and-file-transformations)
  - [**Full list of image/file processing operations**](#full-list-of-image-processing-operations)
- [**Files**](#files)
  - [**Get file info**](#get-file-info)
  - [**Get list of files**](#get-list-of-files)
  - [**Remove files**](#remove-files)
  - [**Store files**](#store-files)
  - [**Metadata**](#metadata)
  - [**Create file copies**](#create-file-copies)
- [**Groups**](#groups)
- [**Video processing**](#video-processing)
- [**Document conversion**](#document-conversion)
- [**Addons**](#addons)
  - [**Object recognition**](#object-recognition)
  - [**Malware protection**](#malware-protection)
  - [**Background removal**](#background-removal)
- [**Webhooks**](#webhooks)
- [**Project**](#project)
- [**FAQ**](#faq)

### Note about `uploadcare_flutter` package

The `uploadcare_flutter` package introduced a few extensions for the base package (`Dimensions`, `Offsets`, `FaceRect`, `FacesEntityExtension`), `UploadcareImageProvider`. If you don't need these features, you can use `uploadcare_client` directly

### Installation

Dart:

```sh
dart pub add uploadcare_client # or uploadcare_flutter
```

Flutter:

```sh
flutter pub add uploadcare_client # or uploadcare_flutter
```

Create an `client`

```dart
final client = UploadcareClient.withSimpleAuth(
  publicKey: 'puplic_key',
  apiVersion: 'v0.7',
);
```

`UploadcareClient` has following API sections

```dart
final ApiUpload upload;
final ApiFiles files;
final ApiGroups groups;
final ApiDocumentConverting documentConverting;
final ApiVideoEncoding videoEncoding;
final ApiAddons addons;
final ApiWebhooks webhooks;
final ApiProject project;
```

You can use each API section separately, for example:

```dart
final options = ClientOptions(
  authorizationScheme: AuthSchemeRegular(
    apiVersion: 'v0.7',
    publicKey: 'public_key',
    privateKey: 'private_key',
  )
);

final upload = ApiUpload(options: options);
final fileId = await upload.base(UCFile(File('...some/file')));
// ...etc.
```

### Upload

#### Base upload

```dart
/// For small files
final fileId = await client.upload.base(UCFile(File('path/to/small_file')));
```

#### Chunked upload

```dart
/// For large files
/// You can manage the number of concurrent requests by setting `ClientOptions.maxConcurrentChunkRequests` field.
final fileId = await client.upload.multipart(UCFile(File('path/to/large_file')));
```

#### From url

```dart
final fileId = await client.upload.fromUrl('https://files.st/path_to_file');
```

#### Auto

```dart
/// Auto method accepts small/large/url files as a parameter and calls the necessary method for upload
final fileId1 = await client.upload.auto(UCFile(File('path/to/small_file')));
final fileId2 = await client.upload.auto(UCFile(File('path/to/large_file')));
final fileId3 = await client.upload.auto('https://files.st/path_to_file');
```

#### Isolate

```dart
/// Also files can be uploaded in dart `isolate`
/// You can manage the number of isolates by setting `ClientOptions.maxIsolatePoolSize` field.
///
/// NOTE: Doesn't work in web environment
final fileId = await client.upload.auto(UCFile(File('path/to/file')), runInIsolate: true);
```

#### Progress tracking

```dart
/// Also you can track upload progress, all methods accept `onProgress` callback for this
final fileId = await client.upload.(auto|base|multipart|fromUrl)(UCFile(File('path/to/file')), onProgress: (progress) => print(progress));
```

#### Cancellable

```dart
/// All upload processes can be canceled with `CancelToken`
final cancelToken = CancelToken();

Timer(Duration(seconds: 1), cancelToken.cancel);

try {
  final fileId = await client.upload.auto(UCFile(File('/some/file')), cancelToken: cancelToken);
} on CancelUploadException catch (e) {
  // cancelled
}

```

#### Signed upload

[Official documentation](https://uploadcare.com/docs/security/secure-uploads/)

```dart
/// For signed upload you should provide the project's private key
final client = UploadcareClient(options: ClientOptions(
  authorizationScheme: AuthSchemeRegular(
    publicKey: 'public_key',
    privateKey: 'private_key',
    apiVersion: 'v0.7',
  ),
  useSignedUploads: true,

  /// Optionally you can customize signature lifetime for signed uploads via the `signedUploadsSignatureLifetime` property (default: 30 minutes)
));

/// Now, all your uploads will be signed
await client.uploads.(base|multipart|fromUrl|auto)(UCFile(File('path/to/file')));
```

### Image and file transformations

[Official documentation](https://uploadcare.com/docs/transformations/image/)

```dart
final cropedCdnImage = CdnImage('<image-uuid>')..transform(CropTransformation(ascpectRatio: AspectRatio(9, 16)));

/// Use the following field for the croped image
/// cropedCdnImage.url;

final cropedAndInlined = CdnImage('<image-uuid>')..transformAll([
  CropTransformation(ascpectRatio: AspectRatio(9, 16)),
  InlineTransformation(true);
]);

/// Use the following field to download the croped image
/// cropedAndInlined.url
```

If you use `uploadcare_flutter` you can specify the provider for the `Image` widget

```dart
final image = Image(
  image: UploadcareImageProvider(
    '<image-uuid>',
    transformations: [
      ImageResizeTransformation(
          const Dimensions.fromHeight(1000)),
    ],
),
```

#### Full list of image processing operations

**Compression:**

| Operation                                                                                                           | Type                        |
| ------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| [Format](https://uploadcare.com/docs/transformations/image/compression/#operation-format)                           | `ImageFormatTransformation` |
| [Quality, SmartCompression](https://uploadcare.com/docs/transformations/image/compression/#operation-quality)       | `QualityTransformation`     |
| [Progressive JPEG](https://uploadcare.com/docs/transformations/image/compression/#operation-progressive)            | `ProgressiveTransformation` |
| [Meta information control](https://uploadcare.com/docs/transformations/image/compression/#meta-information-control) | `StripMetaTransformation`   |

**Resize, Crop, Rotate:**

| Operation                                                                                                               | Type                         |
| ----------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| [Preview](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-preview)                             | `PreviewTransformation`      |
| [Resize, Smart resize](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-resize)                 | `ImageResizeTransformation`  |
| [Crop, Crop by ratio, Crop by objects](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-crop)   | `CropTransformation`         |
| [Scale crop, Smart crop](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-scale-crop)           | `ScaleCropTransformation`    |
| [Border radius and circle crop](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-border-radius) | `BorderRadiusTransformation` |
| [Set fill color](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-setfill)                      | `SetFillTransformation`      |
| [Zoom objects](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-zoom-objects)                   | `ZoomObjectTransformation`   |
| [Automatic rotation, EXIF-based](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-autorotate)   | `AutoRotateTransformation`   |
| [Manual rotation](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-rotate)                      | `RotateTransformation`       |
| [Flip](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-flip)                                   | `FlipTransformation`         |
| [Mirror](https://uploadcare.com/docs/transformations/image/resize-crop/#operation-mirror)                               | `MirrorTransformation`       |

**Overlays and watermarks:**

| Operation                                                                                               | Type                        |
| ------------------------------------------------------------------------------------------------------- | --------------------------- |
| [Image overlay, Self overlay](https://uploadcare.com/docs/transformations/image/overlay/#overlay-image) | `OverlayTransformation`     |
| [Text overlay](https://uploadcare.com/docs/transformations/image/overlay/#overlay-text)                 | `TextOverlayTransformation` |

**Effects and enhancements:**

| Operation                                                                                              | Type                                                                                      |
| ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| [Color adjustment](https://uploadcare.com/docs/effects-enhancements/#image-colors-operations)          | `Color(Brightness\|Exposure\|Gamma\|Contrast\|Sauration\|Vibrance\|Warmth)Transformation` |
| [Enhance](https://uploadcare.com/docs/effects-enhancements/#operation-enhance)                         | `EnhanceTransformation`                                                                   |
| [Grayscale](https://uploadcare.com/docs/effects-enhancements/#operation-grayscale)                     | `GrayscaleTransformation`                                                                 |
| [Inverting](https://uploadcare.com/docs/effects-enhancements/#operation-invert)                        | `InvertTransformation`                                                                    |
| [Conversion to sRGB](https://uploadcare.com/docs/effects-enhancements/#image-color-profile-management) | `SrgbTransformation`                                                                      |
| [ICC profile size threshold](https://uploadcare.com/docs/effects-enhancements/#operation-max-icc-size) | `MaxIccSizeTransformation`                                                                |
| [Photo filters](https://uploadcare.com/docs/effects-enhancements/#image-photo-filters)                 | `FilterTransformation`                                                                    |
| [Blur](https://uploadcare.com/docs/effects-enhancements/#operation-blur)                               | `BlurTransformation`                                                                      |
| [Blur region, Blur faces](https://uploadcare.com/docs/effects-enhancements/#operation-blur-region)     | `BlurRegionTransformation`                                                                |
| [Unsharp masking](https://uploadcare.com/docs/effects-enhancements/#operation-blur-mask)               | `UnsharpMaskingTransformation`                                                            |
| [Sharpen](https://uploadcare.com/docs/effects-enhancements/#operation-sharp)                           | `SharpTransformation`                                                                     |

**Rasterization:**

| Operation                                                               | Type                      |
| ----------------------------------------------------------------------- | ------------------------- |
| [Rasterization](https://uploadcare.com/docs/transformations/image/#svg) | `RasterizeTransformation` |

**Gif to video:**

| Operation                                                                 | Type                       |
| ------------------------------------------------------------------------- | -------------------------- |
| [Gif to video](https://uploadcare.com/docs/transformations/gif-to-video/) | `GifToVideoTransformation` |

```dart
final file = CdnFile('<gif-uuid>')
  ..transform(GifToVideoTransformation([
    VideoFormatTransformation(VideoFormatTValue.Mp4),
    QualityTransformation(QualityTValue.Best),
  ]));

/// Use `file.url` to get video link
```

**Non-image specific operations:**

| Operation                                                                                              | Type                           |
| ------------------------------------------------------------------------------------------------------ | ------------------------------ |
| [Get file info as JSON](https://uploadcare.com/docs/delivery/cdn/#operation-json)                      | `JsonFileInfoTransformation`   |
| [Get file info as `application/javascript`](https://uploadcare.com/docs/delivery/cdn/#operation-jsonp) | `JsonpFileInfoTransformation`  |
| [Show or download](https://uploadcare.com/docs/delivery/cdn/#inline)                                   | `InlineTransformation`         |
| [Change filename](https://uploadcare.com/docs/delivery/cdn/#cdn-filename)                              | `ChangeFilenameTransformation` |

**Face detection:**

[Official documentation](https://uploadcare.com/docs/intelligence/face-detection/)

```dart
/// Detect faces for the image
final FacesEntity entity = await client.files.getFacesEntity('<image-uuid>');
```

### Files

#### Get file info

```dart
/// Get info about the file
final FileInfoEntity file = await client.files.file('<file-uuid>');

/// To get extended file data use `FilesIncludeFields include` field
final FileInfoEntity file = await client.files.file(
  '<file-uuid>',
  include: FilesIncludeFields.withAppData(), /// shortcut for `FilesIncludeFields(predefined: const [FilesIncludeFieldsValue.AppData])`
);
```

#### Get list of files

```dart
/// Get list of files with default params (offset 0, limit 100, ordered by upload time)
final ListEntity<FileInfoEntity> list = await client.files.list();
```

#### Remove files

```dart
/// Remove files by the list of ids
await client.files.remove(['<file-uuid>', '<file-uuid>']);
```

#### Store files

```dart
/// Store files by the list of ids
await client.files.store(['<file-uuid>', '<file-uuid>']);
```

#### Metadata

```dart
/// Retrieve all metadata values of the file
final Map<String, String> metadata = await client.files.getFileMetadata('<file-uuid>');

/// Retrieve the metadata value of the file for the specific metadata key
final String value = await client.files.getFileMetadataValue('<file-uuid>', '<metadata-key>');

/// Update the metadata value of the file for the specific metadata metadata-key
final String updatedValue = await client.files.updateFileMetadataValue('<file-uuid>', '<metadata-key>', '<new-value>');

/// Delete the metadata value of the file for the specific metadata key
await client.files.deleteFileMetadataValue('<file-uuid>', '<metadata-key>');
```

#### Create file copies

```dart
/// Copy original files or their modified versions to a default storage
final FileInfoEntity copiedFile = await client.files.copyToLocalStorage('<file-uuid>', metadata: {'<metadata-key>': '<metadata-value>'});

/// Copy original files or their modified versions to a custom storage
final String remoteFileUrl = await client.files.copyToRemoteStorage(file: '<file-uuid>', target: '<remote-storage>');
```

### Groups

```dart
/// Create a group of files
final GroupInfoEntity group = await client.groups.create({
  /// Without transformation
  '<image-uuid>': [],

  /// With list of transformations
  '<image-uuid>': [RotateTransformation(90)]
});

/// Retrieve group info
final GroupInfoEntity group = await client.groups.group('<group-uuid>');

/// Store all files in the group
await client.groups.storeFiles('<group-uuid>');

/// Retrieve list of groups
final ListEntity<GroupInfoEntity> list = await client.groups.list();

/// Delete the group by id
await client.groups.delete('<group-uuid>');
```

Download group as an archive

```dart
final group = CdnGroup('<group-uuid>')
  ..transform(ArchiveTransformation(ArchiveTValue.Tar, 'archive.tar'));

/// Use the following field for download the group as archive `group.url`
```

### Video processing

[Official documentation](https://uploadcare.com/docs/transformations/video-encoding/)

```dart
/// Create a task for processing uploaded video files
final ConvertEntity<VideoEncodingResultEntity> result = await client.videoEncoding.process({
  '<video-file-uuid>': [
    /// Cut video from 10 to 40 seconds
    CutTransformation(
      const Duration(seconds: 10),
      length: const Duration(
        seconds: 30,
      ),
    )
  ],
  '<video-file-uuid>': [
    /// Change video resolution
    VideoResizeTransformation(const Size(512, 384)),
    /// Generate 10 thumbnails for the video
    VideoThumbsGenerateTransformation(10),
  ],
});

/// Checks processing status for the task
final Stream<ConvertJobEntity<VideoEncodingResultEntity>> processingStream = client.videoEncoding.statusAsStream(
  result.results.first.token,
  checkInterval: const Duration(seconds: 2),
)..listen((ConvertJobEntity<VideoEncodingResultEntity> status) {
  // do something
});
```

### Document conversion

[Official documentation](https://uploadcare.com/docs/transformations/document-conversion/)

```dart
/// Create a task for processing uploaded document files
final ConvertEntity<DocumentConvertingResultEntity> result = client.documentConverting.process({
  '<document-file-uuid>': [
    /// Convert document to pdf
    DocumentFormatTransformation(DucumentOutFormatTValue.PDF),
  ],
  '<document-file-uuid>': [
    /// Converts the 10th page of the document
    DocumentFormatTransformation(DucumentOutFormatTValue.PNG, page: 10),
  ],
});

/// Checks processing status for the task
final Stream<ConvertJobEntity<DocumentConvertingResultEntity>> processingStream = client.documentConverting.statusAsStream(
  result.results.first.token,
  checkInterval: const Duration(seconds: 2),
)..listen((ConvertJobEntity<DocumentConvertingResultEntity> status) {
  // do something
});
```

### Addons

#### Object recognition

[Official documentation](https://uploadcare.com/docs/intelligence/object-recognition/)

```dart
final taskId = await client.addons.executeAWSRekognition('<image-uuid>');

final result = await client.addons.checkAWSRekognitionExecutionStatus(taskId);

if (result.status == AddonExecutionStatusValue.Done) {
  /// Retrieve file info with appdata fields
  final file = await client.files.file('<image-uuid>', include: FilesIncludeFields.withAppData());

  /// Now you can access recognition info with the following field
  final recognitionData = file.appData.awsRecognition;
}
```

#### Malware protection

[Official documentation](https://uploadcare.com/docs/security/malware-protection/)

```dart
final taskId = await client.addons.executeClamAV('<file-uuid>');

final result = await client.addons.checkClamAVExecutionStatus(taskId);

if (result.status == AddonExecutionStatusValue.Done) {
  /// Retrieve file info with appdata fields
  final file = await client.files.file('<file-uuid>', include: FilesIncludeFields.withAppData());

  /// Now you can access clamAV result with the following field
  final clamAVData = file.appData.clamAV;
}
```

#### Background removal

[Official documentation](https://uploadcare.com/docs/remove-bg/)

```dart
final taskId = await client.addons.executeRemoveBg('<image-uuid>');

final result = await client.addons.checkRemoveBgExecutionStatus(taskId);

if (result.status == AddonExecutionStatusValue.Done) {
  /// Retrieve file info with appdata fields
  final file = await client.files.file('<image-uuid>', include: FilesIncludeFields.withAppData());

  /// Now you can access removeBg result with the following field
  final removeBgData = file.appData.removeBg;
}
```

### Webhooks

[Official documentation](https://uploadcare.com/docs/webhooks/)

```dart
/// Get list of project webhooks
final List<WebhookEntity> hooks = await client.webhooks.list();

/// Create webhook
final WebhookEntity webhook = await client.webhooks.create(targetUrl: '<webhook-endpoint>', event: WebhookEvent.Uploaded);

/// Update webhook
final WebhookEntity webhook = await client.webhooks.update(hookId: '<webhook-id>', isActive: false);

/// Delete webhook
await client.webhooks.delete('<webhook-endpoint>');
```

### Project

```dart
/// Get project common information
final ProjectEntity info = await client.project.info();
```

### FAQ

- How to pick files on different platforms?
  - [See uploadcare example project](https://github.com/KonstantinKai/uploadcare_client/blob/master/uploadcare_flutter_example/lib/screens/home_screen.dart#L4)
