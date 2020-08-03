import 'dart:convert';
import 'package:meta/meta.dart';
import '../api_sections/cdn_file.dart';
import '../entities/entities.dart';
import '../entities/file_info.dart';
import '../entities/list.dart';
import '../mixins/mixins.dart';
import '../options.dart';

/// Provides API for working with files
class ApiFiles with OptionsShortcutMixin, TransportHelperMixin {
  ApiFiles({
    @required this.options,
  }) : assert(options != null);

  @override
  final ClientOptions options;

  /// Retrieve file by [fileId]
  Future<FileInfoEntity> file(
    String fileId, {

    /// Only available since v0.6
    @experimental bool includeRecognitionInfo = false,
  }) async {
    _assertRecongtionApiWithApiVersion(includeRecognitionInfo);
    return FileInfoEntity.fromJson(
      await resolveStreamedResponse(
        createRequest(
          'GET',
          buildUri('$apiUrl/files/$fileId/', {
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
    int offset,
    FilesOrdering ordering =
        const FilesOrdering(FilesFilterValue.DatetimeUploaded),
    dynamic fromFilter,

    /// Only available since v0.6
    @experimental bool includeRecognitionInfo = false,
  }) async {
    assert(limit > 0 && limit <= 1000, 'Should be in 1..1000 range');
    _assertRecongtionApiWithApiVersion(includeRecognitionInfo);

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
            if (stored != null) 'stored': stored.toString(),
            if (removed != null) 'removed': removed.toString(),
            if (offset != null) 'offset': offset.toString(),
            if (fromFilter != null) 'from': fromFilter,
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

  Future<Map<String, dynamic>> _detectFaces(String imageId) {
    final cdnFile = CdnFile(imageId);

    return resolveStreamedResponse(
      createRequest('GET', buildUri('${cdnFile.url}detect_faces/')).send(),
    );
  }

  void _assertRecongtionApiWithApiVersion(bool includeRecognitionInfo) {
    assert(includeRecognitionInfo
        ? double.tryParse(options.authorizationScheme.apiVersion.substring(1)) >
            0.5
        : true);
  }
}
