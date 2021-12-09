## [4.0.0] - Thu Dec 9 2021
* **Breaking changes with 3.x.x**
  * `OverlayCoordinates` was renamed to `Coordinates` and moved to `/lib/src/measures.dart`;
  * Overridden `toString` method for `Dimensions` and `Offsets` to respect new property `units` in this types
  * Changed the second parameter for `CropTransformation` to `Coordinates` from `Offsets`, removed the third `center` parameter, now use `Coordinates` with a predefined parameter instead.
  * `OverlayTransformation` doesn't work with `MeasureUnits.Pixel` in `dimensions` and `coordinates`
* Added `BlurRegionTransformation`
* Added `UnsharpMaskingTransformation`
* Added `FilterTransformation`
* Added `ZoomObjectTransformation`
* Added color adjustment transformations
  * `ColorBrightnessTransformation`
  * `ColorExposureTransformation`
  * `ColorGammaTransformation`
  * `ColorContrastTransformation`
  * `ColorSaturationTransformation`
  * `ColorVibranceTransformation`
  * `ColorWarmthTransformation`
* Added `SrgbTransformation`
* Added `InlineTransformation`
* You can use overlay transformation to the source image, see https://uploadcare.com/docs/transformations/image/overlay/#overlay-self
* Made `Transformation` constructor `const`;
* Added `MeasureUnits` enum to specify units in `Dimensions` and `Offsets` types
* Added units restrictions for transformations that works with `Dimensions` and `Offsets` types
* Added links to the official uploadcare site for each transformation
* Replaced `pedantic` with `lints` for analysis

## [3.0.2] - Sat Mar 6 2021
* Dropped 'dart:isolate' import for unsupported platforms

## [3.0.1] - Sat Mar 6 2021
* Removed all unnecessary links to HTTP headers from `dart:io`

## [3.0.0] - Sat Mar 6 2021
* **Breaking changes with 2.x.x**
  * Added `Null safety`, updated all dependencies
  * Package has been split into 2 libraries, `uploadcare_client` can be used in non-flutter environments, install `uploadcare_flutter` to use with flutter
* Replaced `mime_type` package with `mime` that supports `Null safety`
* Added new entities `Dimensions, Offsets, FaceRect` to drop flutter dependency
* Made the main repository as a monorepo

## [2.1.1] - Mon Aug 3 2020
* Re export `GroupInfoEntity` and `CdnEntity` from main library file (related to: [#2](https://github.com/KonstantinKai/uploadcare_client/issues/2))

## [2.1.0] - Sat May 23 2020
* **Breaking changes with 2.0.0**
  * Changed `ScaleCropTransformation` constructor parameters, accepts the required `size` and optional named `offset`, `type`, `center`
* Added `ScaleCropTypeTValue` as `type`, `Offset` as `offset`, `bool` as `center` parameters to the `ScaleCropTransformation` class
* Added `QualityTValue.Smart` value to the `QualityTransformation` class, but you can use it only with `ImageTransformation`
* Updated dependencies

## [2.0.0] - Tue Dec 17 2019
* **Breaking changes with 1.4.2**
  * The Flutter team made a breaking change with the ImageProvider in Flutter `1.10.15`.
* Changed `UploadcareImageProvider.load` method arguments, related to the SDK changes for `ImageProvider`
* Added ability to upload in `flutter_web` environment
  * Added `SharedFile` abstraction, which works on both `mobile` & `web`
  * Changed `res` argument type in `ApiSectionUpload.auto` method
  * Changed `file` argument type in `ApiSectionUpload.base` & `ApiSectionUpload.multipart` methods
* Added ability to upload files in example project in `flutter_web` environment
* Removed deprecated `detectFaces` method from `ApiFiles`;

## [1.4.2] - Tue Dec 10 2019
* Added flutter SDK version constraint
* Described limitations in README

## [1.4.1] - Mon Dec 9 2019
* Updated dependencies to the latest version

## [1.4.0] - Mon Nov 4 2019
* Improved `auto` method from `ApiUpload`. Now you can pass file string to this method and client try to parse him.
* Added ability to run upload process in separate isolate
* Added `maxIsolatePoolSize` options to `ClientOptions` which control concurrent isolates amount

## [1.3.0] - Fri Nov 1 2019
* Added `FacesEntity` which holds Face Recognition data of an image related to the original size
* Added `getFacesEntity` method to `ApiFiles` which returns `FacesEntity`
* Marked `detectFaces` method to `deprecated`. Use `getFacesEntity` instead.
* Added face recognition screen to the example project

## [1.2.2] - Wed Oct 30 2019
* Fixed case when `content_type` value for upload is null with filenames in uppercase (related to `mime_type` package).

## [1.2.1] - Tue Oct 29 2019
* Refactored `ConcurrentRunner` class

## [1.2.0] - Mon Oct 28 2019
* Added `detectFaces` method for `ApiFiles` section
* Added `OverlayTransformation` applied to an image
* Added `GifToVideoTransformation` applied to gif
* Added `includeRecognitionInfo` parameter to `ApiFiles` section for `file` & `list` methods.
    * **Note**: this feature will be available only since `v0.6` version of REST API
* Covered all transformation with test
* Improved documentation

## [1.1.0] - Fri Oct 25 2019
* Added ability to cancel file upload with `CancelToken`
* Optimized chunked upload
* Changed header names to constants from `dart:io HttpHeaders`
* Fixed progress data with multipart upload
* Refactored example project

## [1.0.2] - Mon Oct 21 2019
* Minor grammatical fixes

## [1.0.1] - Tue Oct 15 2019
* Made `privateKey` optional

## [1.0.0] - Thu Sep 26 2019
* Moved to stable version

## [0.0.1] - Thu Sep 26 2019
* Initial release