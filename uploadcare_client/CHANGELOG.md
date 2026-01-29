## [7.2.0] - Wed Jan 29 2026

- Added `overrideFilename` parameter to upload API (`auto`, `base`, `multipart` methods and isolate upload)
- Added `maxRetries` parameter to `auto`, `base`, and `multipart` upload methods with exponential backoff for transient failures (default: 3 retries)
- Optimized multipart upload:
  - Memory-efficient byte collection using pre-allocated `Uint8List`
  - Simplified chunk action generation
  - Extracted chunk upload logic to dedicated methods
- Extended `TextFontTransformation` with new font properties. See <https://uploadcare.com/docs/transformations/image/overlay/#font-properties>
  - Added `reset` parameter to reset font properties to default
  - Added `weight` parameter (`TextFontWeight`: regular, bold)
  - Added `style` parameter (`TextFontStyle`: normal, italic)
  - Added `family` parameter (`TextFontFamily`: DejaVu, DejaVuMono, DejaVuSerif, Noto, NotoMono, NotoSerif)
  - Made `size` and `color` parameters optional

## [7.1.0] - Mon Mar 10 2025

- Added feature for unsafe content detection via addons. See <https://uploadcare.com/docs/unsafe-content/>
  - Added the relevant API to `ApiAddons`
  - Added the relevant entities
  - Added field `AWSRekognitionModerationAddonResult? awsRecognitionModeration` to the file's `AppData`
- Replaced `dart:html` with `package:web` and `dart:js_interop` due the deprecation
- Updated dependencies
- Minor changes according to the analyzer

## [7.0.0] - Thu Oct 26 2023

- Updated SDK constraints to add the ability to work with Dart 3
- Updated dependencies
- Added new values to the `WebhookEvent`. See <https://uploadcare.com/docs/webhooks>
- Added `ImageFormatTValue.Preserve` value. See <https://uploadcare.com/docs/transformations/image/compression/#operation-format>
- Minor code styles changes according to the analyzer
- Minor typos fixes
- Use pattern matching instead of `if` in `enum`s `parse` methods

## [6.3.2] - Fri May 12 2023

- Added package topics to the pubspec

## [6.3.1] - Thu May 11 2023

- README.md

## [6.3.0] - Wed May 10 2023

- Fixed access with `AuthSchemeRegular` for the web due to the `Date` header limitation. Used the same header as in an official javascript library;
- Added `RasterizeTransformation`. See <https://uploadcare.com/docs/transformations/image/#svg>
- Added `BorderRadiusTransformation`. See <https://uploadcare.com/docs/transformations/image/resize-crop/#operation-border-radius>
- Added `RectOverlayTransformation`. See <https://uploadcare.com/docs/transformations/image/overlay/#overlay-solid>
- Added `TextOverlayTransformation`. See <https://uploadcare.com/docs/transformations/image/overlay/#overlay-text>
- Added `useSmartResize` to the `ImageResizeTransformation`. See <https://uploadcare.com/docs/transformations/image/resize-crop/#operation-smart-resize>
- Added `JsonpFileInfoTransformation`. See <https://uploadcare.com/docs/delivery/cdn/#operation-jsonp>
- Added `ChangeFilenameTransformation`. See <https://uploadcare.com/docs/delivery/cdn/#cdn-filename>
- Rewritten README.md

## [6.2.1] - Fri Nov 11 2022

- Reduced `meta` dependency version to `1.7.0` because of version conflict with the `flutter_test` package in `uploadcare_flutter` lib

## [6.2.0] - Fri Sep 30 2022

- Added `ApiAddons` section. See <https://uploadcare.com/api-refs/rest-api/v0.7.0/#tag/Add-Ons>
- Added `ApiFiles.copyToLocalStorage` method. See <https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/createLocalCopy>
- Added `ApiFiles.copyToRemoteStorage` method. See <https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/createRemoteCopy>
- Added `include` parameter to `ApiFiles.file` & `ApiFiles.list` methods
- Added `FileInfoEntity.appData` field
- Marked `ApiFiles.getApplicationData` & `ApiFiles.getApplicationDataByAppName` as deprecated due the api changes
- Marked `includeRecognitionInfo` for `ApiFiles.file` & `ApiFiles.list` methods as deprecated due the api changes (use `AWSRecognition` from `ApiAddons`)
- Marked `FileInfoEntity.recognitionInfo` as deprecated
- Added addons usage to the example project

## [6.1.1] - Wed July 27 2022

- Made `VideoStreamMetadata.bitrate` as `nullable`
- Update android project for example folder

## [6.1.0] - Mon May 30 2022

- Added `file's application data` methods to `ApiFiles` section. See <https://uploadcare.com/api-refs/rest-api/v0.7.0/#tag/Application-Data>
- Added `ApiProject` section. See <https://uploadcare.com/api-refs/rest-api/v0.7.0/#tag/Project>
- Added `X-UC-User-Agent` header to requests

## [6.0.1] - Thu May 26 2022

- Changed `VideoStreamMetadata.frameRate` from `int` to `num`
- Added new fields to `FileInfoEntity.props`

## [6.0.0] - Thu May 26 2022

- **Breaking changes with 5.x.x**
  - Increased dart SDK to the latest stable, not compatible with lower versions
  - Made `ListEntity.nextUrl` and `nextUrl.previousUrl` nullable according to the official documentation
  - Made `UrlUploadStatusEntity.status` non nullable
  - Changed error type from `Exception` to `AssertionError` which can be thrown from `ApiUpload.auto`
  - Changed `FileInfoEntity.imageInfo` from `Map` to `ImageInfo`
  - Renamed `SharedFile` to `UCFile`
  - Removed `implements ImageTransformation` from `InlineTransformation` and moved it to the common folder
  - Refactored whole video encoding API due to the similar functionality with the document conversion API
    - Removed `VideoEncodingJobStatusValue` use `ConvertJobStatusValue` instead
    - Removed `VideoEncodingJobEntity` use `ConvertJobEntity<VideoEncodingResultEntity>` instead
    - Removed `VideoEncodingConvertEntity` use `ConvertEntity<VideoEncodingResultEntity>` instead
    - Createt `ConvertMixin` that simplify creating of conversion API
- **Features**
  - Added `ApiWebhooks` section, respectively added as a field to `UploadcareClient.webhooks`. See <https://uploadcare.com/api-refs/rest-api/v0.6.0/#tag/Webhook>
  - Added `ApiDocumentConverting` section, respectively added as a field to `UploadcareClient.documentConverting`. See <https://uploadcare.com/docs/transformations/document-conversion/>
  - Added `DocumentTransformation` as a base transformation for documents
  - Added `DocumentFormatTransformation`
  - Added metadata methods to the `ApiFiles` section. See <https://uploadcare.com/api-refs/rest-api/v0.7.0/#tag/File-Metadata>, respectively added `metadata` field to the `FileInfoEntity`
  - Added ability to save file metadata while uploading
  - Added `checkURLDuplicates` and `saveURLDuplicates` parameters for `ApiUploads.fromUrl` method
  - Added `VideoInfo` to the `FileInfoEntity`. Works since `v0.6` API
  - Added `ListEntityTotals` to the `ListEntity`
  - Added `FileInfoEntity.variations` field
  - Added `FileInfoEntity.isVideo` field
  - Added `ApiGroups.delete` method
  - Improved `uploadcare_flutter_example` (works on web/mobile/desktop)
    - Added buttons for work with `v0.6` and `v0.7` API
    - Added `FileInfoScreen` with file metadata and the ability to download a file
    - Added `PreviewFileScreen` only for images at the moment
  - Created uc server mock for tests
  - Covered more API with tests
- **Fixes**
  - Added `UrlUploadStatusValue.Waiting` status
  - Fixed `ApiUpload.fromUrl` when status has `UrlUploadStatusValue.Waiting` value
  - Fixed `ApiUpload.fromUrl` when the URL was previously downloaded, and no need to wait for the status again
  - Fixed `CdnPathBuilderMixin.uri` field when url has an initial pathname
  - Fixed `TransportHelperMixin` when the server returns a status code greater than 201 (till 204 is a valid status response)
  - Fixed `CancelUploadException.toString` method that returned the wrong value for an empty message

## [5.0.1] - Fri Apr 1 2022

- Fixed analyzer warnings

## [5.0.0] - Thu Mar 31 2022

- **Breaking changes with 4.x.x**
  - `CropTransformation` changed constructor parameters according to the last transform API changes
- Added ability to crop image by ratio for the `CropTransformation`. See <https://uploadcare.com/docs/transformations/image/resize-crop/#operation-crop-aspect-ratio>
- Added ability to crop image by objects for the `CropTransformation`. See <https://uploadcare.com/docs/transformations/image/resize-crop/#operation-crop-tags>
- Added `StripMetaTransformation`
- Added `QualityTValue.SmartRetina` value for the `QualityTransformation`.
- Added the following tarnsformation `PreviewTransformation, ResizeTransformation, CropTransformation, ScaleCropTransformation` to the `GifToVideoTransformation`
- Added `JsonFileInfoTransformation`
- Added `AspectRatio` entity according to the `CropTransformation` changes
- Fixes.

## [4.0.1] - Thu Dec 9 2021

- Remove unnecessary check

## [4.0.0] - Thu Dec 9 2021

- **Breaking changes with 3.x.x**
  - `OverlayCoordinates` was renamed to `Coordinates` and moved to `/lib/src/measures.dart`;
  - Overridden `toString` method for `Dimensions` and `Offsets` to respect new property `units` in this types
  - Changed the second parameter for `CropTransformation` to `Coordinates` from `Offsets`, removed the third `center` parameter, now use `Coordinates` with a predefined parameter instead.
  - `OverlayTransformation` doesn't work with `MeasureUnits.Pixel` in `dimensions`
- Added `BlurRegionTransformation`
- Added `UnsharpMaskingTransformation`
- Added `FilterTransformation`
- Added `ZoomObjectTransformation`
- Added color adjustment transformations
  - `ColorBrightnessTransformation`
  - `ColorExposureTransformation`
  - `ColorGammaTransformation`
  - `ColorContrastTransformation`
  - `ColorSaturationTransformation`
  - `ColorVibranceTransformation`
  - `ColorWarmthTransformation`
- Added `SrgbTransformation`
- Added `InlineTransformation`
- You can use overlay transformation to the source image, see <https://uploadcare.com/docs/transformations/image/overlay/#overlay-self>
- Made `Transformation` constructor `const`;
- Added `MeasureUnits` enum to specify units in `Dimensions` and `Offsets` types
- Added units restrictions for transformations that works with `Dimensions` and `Offsets` types
- Added links to the official uploadcare site for each transformation
- Replaced `pedantic` with `li
