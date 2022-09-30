import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'utils.dart';

class FileMetadataRoutes {
  FileMetadataRoutes(Router router) {
    router
      ..get('/files/<fileId>/metadata/', _fileMetadata)
      ..get('/files/<fileId>/metadata/<metadataKey>/', _fileMetadataValue)
      ..put('/files/<fileId>/metadata/<metadataKey>/', _updateFileMetadataValue)
      ..delete(
          '/files/<fileId>/metadata/<metadataKey>/', _deleteFileMetadataValue);
  }

  Response _fileMetadata(Request request, String fileId) {
    return Response.ok(jsonEncode({'key1': 'value1', 'fileId': fileId}),
        headers: const {'Content-Type': 'application/json'});
  }

  Response _fileMetadataValue(
      Request request, String fileId, String metadataKey) {
    return Response.ok(jsonEncode('value1_${fileId}_$metadataKey'),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _updateFileMetadataValue(
      Request request, String fileId, String metadataKey) async {
    final payload = await Utils.parseJsonBodyAsString(request);
    return Response.ok(jsonEncode('${payload}_${fileId}_$metadataKey'),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _deleteFileMetadataValue(
      Request request, String fileId, String metadataKey) async {
    return Response.ok(jsonEncode('ok'),
        headers: const {'Content-Type': 'application/json'});
  }
}
