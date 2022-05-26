import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class FileRoutes {
  FileRoutes(Router router, this.assets) {
    router
      ..get('/files/', _files)
      ..get('/files/<fileId>/', _fileInfo)
      ..delete('/files/storage/', _filesDelete)
      ..get('/fakefile/<filename>', _fakeFile);
  }

  final String assets;

  Future<Response> _files(Request request) async {
    final version = request.context['version']!;
    final file = File(path.join(assets, 'file_list_$version.json'));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _fileInfo(Request request, String fileId) async {
    final version = request.context['version']!;
    final res = fileId == '7ed2aed0-0482-4c13-921b-0557b193edc2'
        ? 'file_info_video_$version.json'
        : 'file_info_image_$version.json';
    final file = File(path.join(assets, res));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _filesDelete(Request request) async {
    final payload = jsonDecode(await request.readAsString()) as List;

    if (payload.isEmpty) {
      return Response.badRequest();
    }

    return Response.ok(jsonEncode('ok'),
        headers: const {'Content-Type': 'application/json'});
  }

  Response _fakeFile(Request request, String filename) {
    final file = File(path.join(assets, filename));
    return Response.ok(file.openRead(),
        headers: {'Content-Type': 'application/octet-stream'});
  }
}
