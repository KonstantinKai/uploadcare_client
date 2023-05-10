import 'dart:convert';
import '../api_sections/cdn_file.dart';
import '../entities/entities.dart';
import '../mixins/mixins.dart';
import '../options.dart';

/// Provides API for working with files
class ApiFiles with OptionsShortcutMixin, TransportHelperMixin {
  ApiFiles({
    required this.options,
  });

  @override
  final ClientOptions options;

  /// Retreive file by [fileId]
  Future<FileInfoEntity> file(
    String fileId, {
    /// Since v0.7
    /// Include additional fields to the file object, such as: appdata
    FilesIncludeFields? include,

    /// Only v0.6
    @Deprecated('Due to the API stabilizing recognition feature moved to the [ApiAddons]')
        bool includeRecognitionInfo = false,
  }) async {
    _ensureRightVersionForRecognitionApi(includeRecognitionInfo);

    if (include != null) _ensureRightVersionForApplicationData();

    return FileInfoEntity.fromJson(
      await resolveStreamedResponse(
        createRequest(
          'GET',
          buildUri('$apiUrl/files/$fileId/', {
            if (include != null) 'include': include.toString(),
            if (includeRecognitionInfo) 'add_fields': 'rekognition_info',
          }),
        ).send(),
      ),
    );
  }

  /// Batch file delete
  Future<void> remove(List<String> fileIds) async {
    assert(fileIds.length <= 100, 'Can be removed up to 100 files per request');

    final request = createRequest(
      'DELETE',
      buildUri('$apiUrl/files/storage/'),
    )..body = jsonEncode(fileIds);

    await resolveStreamedResponseStatusCode(request.send());
  }

  /// Store files by [fileIds]
  Future<void> store(List<String> fileIds) async {
    assert(fileIds.length <= 100, 'Can be stored up to 100 files per request');

    final request = createRequest('PUT', buildUri('$apiUrl/files/storage/'))
      ..body = jsonEncode(fileIds);

    await resolveStreamedResponseStatusCode(request.send());
  }

  /// Retrieve files
  ///
  /// [stored] `true` to only include files that were stored, `false` to include temporary ones.
  /// [removed] `true` to only include removed files in the response, `false` to include existing files.
  /// [limit] a preferred amount of files in a list for a single response.
  /// [ordering] specifies the way files are sorted in a returned list
  /// [fromFilter] a starting point for filtering files. The value depends on your ordering parameter value.
  Future<ListEntity<FileInfoEntity>> list({
    bool stored = true,
    bool removed = false,
    int limit = 100,
    int? offset,
    FilesOrdering ordering =
        const FilesOrdering(FilesFilterValue.DatetimeUploaded),
    dynamic fromFilter,

    /// Since v0.7
    /// Include additional fields to the file object, such as: appdata
    FilesIncludeFields? include,

    /// Only v0.6
    @Deprecated('Due to the API stabilizing recognition feature moved to the [ApiAddons]')
        bool includeRecognitionInfo = false,
  }) async {
    assert(limit > 0 && limit <= 1000, 'Should be in 1..1000 range');
    _ensureRightVersionForRecognitionApi(includeRecognitionInfo);

    if (include != null) _ensureRightVersionForApplicationData();

    if (fromFilter != null) {
      if (ordering.field == FilesFilterValue.DatetimeUploaded) {
        assert(
          fromFilter is DateTime,
          'fromFilter should be an DateTime for datetime_uploaded ordering',
        );
        fromFilter = (fromFilter as DateTime).toIso8601String();
      } else if (ordering.field == FilesFilterValue.Size) {
        assert(
          fromFilter is int && fromFilter > 0,
          'fromFilter should be an positive integer for size ordering',
        );
        fromFilter = fromFilter.toString();
      }
    }

    final response = await resolveStreamedResponse(
      createRequest(
          'GET',
          buildUri('$apiUrl/files/', {
            'limit': limit.toString(),
            'ordering': ordering.toString(),
            'stored': stored.toString(),
            'removed': removed.toString(),
            if (offset != null) 'offset': offset.toString(),
            if (fromFilter != null) 'from': fromFilter,
            if (include != null) 'include': include.toString(),
            if (includeRecognitionInfo) 'add_fields': 'rekognition_info',
          })).send(),
    );

    return ListEntity.fromJson(
      response,
      (response['results'] as List)
          .map((item) => FileInfoEntity.fromJson(item))
          .toList(),
    );
  }

  /// Returns [FacesEntity] which contains original image size and rectangles of faces
  ///
  /// Example:
  /// ```dart
  /// FacesEntity entity = /* FacesEntity */
  /// RenderBox renderBox = context.findRenderObject();
  ///
  /// return FractionallySizedBox(
  ///   widthFactor: 1,
  ///   heightFactor: 1,
  ///   child: Stack(
  ///     children: <Widget>[
  ///       Positioned.fill(
  ///         child: Image(
  ///           image: UploadcareImageProvider(widget.imageId),
  ///           fit: BoxFit.contain,
  ///           alignment: Alignment.topCenter,
  ///         ),
  ///       ),
  ///       ...entity
  ///           .getRelativeFaces(
  ///         Size(
  ///           renderBox.size.width,
  ///           renderBox.size.width /
  ///               entity.originalSize.aspectRatio,
  ///         ),
  ///       )
  ///           .map((face) {
  ///         return Positioned(
  ///           top: face.top,
  ///           left: face.left,
  ///           child: Container(
  ///             width: face.size.width,
  ///             height: face.size.height,
  ///             decoration: BoxDecoration(
  ///               color: Colors.black12,
  ///               border: Border.all(color: Colors.white54, width: 1.0),
  ///             ),
  ///           ),
  ///         );
  ///       }).toList(),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<FacesEntity> getFacesEntity(String imageId) async {
    final response = await _detectFaces(imageId);

    return FacesEntity.fromJson(response);
  }

  Future<dynamic> _detectFaces(String imageId) {
    final cdnFile = CdnFile(imageId, cdnUrl: cdnUrl);

    return resolveStreamedResponse(
      createRequest('GET', buildUri('${cdnFile.url}detect_faces/'), false)
          .send(),
    );
  }

  /// **Since v0.7**
  /// Get file's metadata keys and values
  Future<Map<String, String>> getFileMetadata(String fileId) async {
    _ensureRightVersionForMetadataApi();

    final result = await resolveStreamedResponse(
      createRequest(
        'GET',
        buildUri('$apiUrl/files/$fileId/metadata/'),
      ).send(),
    );

    return (result as Map).cast<String, String>();
  }

  /// **Since v0.7**
  /// Get the value of a single metadata key
  Future<String> getFileMetadataValue(String fileId, String metadataKey) async {
    _ensureRightVersionForMetadataApi();

    final result = await resolveStreamedResponse(
      createRequest(
        'GET',
        buildUri('$apiUrl/files/$fileId/metadata/$metadataKey/'),
      ).send(),
    );

    return result as String;
  }

  /// **Since v0.7**
  /// Update the value of a single metadata key. If the key does not exist, it will be created
  Future<String> updateFileMetadataValue(
      String fileId, String metadataKey, String value) async {
    _ensureRightVersionForMetadataApi();

    final request = createRequest(
      'PUT',
      buildUri('$apiUrl/files/$fileId/metadata/$metadataKey/'),
    )..body = jsonEncode(value);

    final result = await resolveStreamedResponse(request.send());
    return result as String;
  }

  /// **Since v0.7**
  /// Delete a file's metadata key
  Future<void> deleteFileMetadataValue(
      String fileId, String metadataKey) async {
    _ensureRightVersionForMetadataApi();

    await resolveStreamedResponse(
      createRequest(
        'DELETE',
        buildUri('$apiUrl/files/$fileId/metadata/$metadataKey/'),
      ).send(),
    );
  }

  /// **Since v0.6**
  ///
  /// POST requests are used to copy original files or their modified versions to a default storage.
  ///
  /// Source files MAY either be stored or just uploaded and MUST NOT be deleted.
  ///
  /// Copying of large files is not supported at the moment.
  /// If the file CDN URL includes transformation operators, its size MUST NOT exceed 100 MB. If not, the size MUST NOT exceed 5 GB.
  Future<FileInfoEntity> copyToLocalStorage(
    String fileId, {
    /// The parameter only applies to the Uploadcare storage and MUST be either true or false.
    ///
    /// Default: false
    bool? store,

    /// **Since v0.7**
    ///
    /// Arbitrary additional metadata.
    Map<String, String>? metadata,
  }) async {
    _ensureRightVersionForCopyApi();
    if (metadata != null) _ensureRightVersionForMetadataApi();

    final request = createRequest('POST', buildUri('$apiUrl/files/local_copy/'))
      ..body = jsonEncode({
        'source': fileId,
        if (store != null) 'store': store.toString(),
        if (metadata != null) 'metadata': metadata,
      });

    final response =
        (await resolveStreamedResponse(request.send())) as Map<String, dynamic>;

    return FileInfoEntity.fromJson(response['result']);
  }

  /// **Since: v0.6**
  ///
  /// POST requests are used to copy original files or their modified versions to a custom storage.
  ///
  /// Source files MAY either be stored or just uploaded and MUST NOT be deleted.
  ///
  /// Copying of large files is not supported at the moment. File size MUST NOT exceed 5 GB.
  Future<String> copyToRemoteStorage({
    required String fileId,
    required String target,
    bool? makePublic,

    /// The parameter is used to specify file names Uploadcare passes to a custom storage.
    /// If the parameter is omitted, your custom storages pattern is used. Use any combination of allowed values.
    ///
    /// Default: FilesPatternValue.Default
    FilesPatternValue? pattern,
  }) async {
    _ensureRightVersionForCopyApi();

    final request =
        createRequest('POST', buildUri('$apiUrl/files/remote_copy/'))
          ..body = jsonEncode({
            'source': fileId,
            'target': target,
            if (makePublic != null) 'make_public': makePublic.toString(),
            if (pattern != null) 'pattern': pattern.toString(),
          });

    final response =
        (await resolveStreamedResponse(request.send())) as Map<String, dynamic>;

    return response['result'];
  }

  /// **Since v0.7**
  ///
  /// Get file's application data from all applications at once
  /// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/getAllApplicationData
  @Deprecated(
      'Moved to [ApiAddons] section. Will be removed in next major release. See https://uploadcare.com/api-refs/rest-api/v0.7.0/#tag/Add-Ons')
  Future<Map<String, dynamic>> getApplicationData(String fileId) async {
    _ensureRightVersionForApplicationData();

    final result = await resolveStreamedResponse(
      createRequest(
        'GET',
        buildUri('$apiUrl/files/$fileId/appdata/'),
      ).send(),
    );

    return (result as Map).cast<String, dynamic>();
  }

  /// **Since v0.7**
  ///
  /// Get file's application data from a single application
  /// See https://uploadcare.com/api-refs/rest-api/v0.7.0/#operation/getSingleApplicationData
  @Deprecated(
      'Moved to [ApiAddons] section. Will be removed in next major release. See https://uploadcare.com/api-refs/rest-api/v0.7.0/#tag/Add-Ons')
  Future<Map<String, dynamic>> getApplicationDataByAppName(
      String fileId, String appName) async {
    _ensureRightVersionForApplicationData();

    final result = await resolveStreamedResponse(
      createRequest(
        'GET',
        buildUri('$apiUrl/files/$fileId/appdata/$appName/'),
      ).send(),
    );

    return (result as Map).cast<String, dynamic>();
  }

  void _ensureRightVersionForRecognitionApi(bool includeRecognitionInfo) {
    if (!includeRecognitionInfo) return;

    ensureRightVersion(0.6, 'Recognition API', exact: true);
  }

  void _ensureRightVersionForMetadataApi() {
    ensureRightVersion(0.7, 'Metadata API');
  }

  void _ensureRightVersionForApplicationData() {
    ensureRightVersion(0.7, 'File application data API');
  }

  void _ensureRightVersionForCopyApi() {
    ensureRightVersion(0.6, 'File copy API');
  }
}
