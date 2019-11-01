## [1.3.0] - Fri Nov 1 2019

* Add `FacesEntity` which holds Face Recognition data of an image related to the original size
* Add `getFacesEntity` method to `ApiFiles` which returns `FacesEntity`
* Add `detectFaces` method to `deprecated`. Use `getFacesEntity` instead.
* Add face recognition screen to the example project

## [1.2.2] - Wed Oct 30 2019

* Fix case when `content_type` value for upload is null with filenames in uppercase (related to `mime_type` package).

## [1.2.1] - Tue Oct 29 2019

* Refactor `ConcurrentRunner` class

## [1.2.0] - Mon Oct 28 2019

* Add `detectFaces` method for `ApiFiles` section
* Add `OverlayTransformation` applied to an image
* Add `GifToVideoTransformation` applied to gif
* Add `includeRecognitionInfo` parameter to `ApiFiles` section for `file` & `list` methods.
    * **Note**: this feature will be available only since `v0.6` version of REST API
* Cover all transformation with test
* Improve documentation

## [1.1.0] - Fri Oct 25 2019

* Add ability to cancel file upload with `CancelToken`
* Optimize chunked upload
* Change header names to constants from `dart:io HttpHeaders`
* Fix progress data with multipart upload
* Refactor example project

## [1.0.2] - Mon Oct 21 2019

* Minor grammatical fixes

## [1.0.1] - Tue Oct 15 2019

* Make `privateKey` optional

## [1.0.0] - Thu Sep 26 2019

* Move to stable version

## [0.0.1] - Thu Sep 26 2019

* Initial release
