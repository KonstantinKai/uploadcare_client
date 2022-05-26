import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:path/path.dart' as path;
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

class UploadRoutes {
  UploadRoutes(Router router, this.assets) {
    router
      ..post('/upload/base/', _base)
      ..post('/upload/multipart/start/', _multipartStart)
      ..post('/upload/multipart/complete/', _multipartComplete)
      ..put('/upload/multipart/<individualFile>/', _multipartIndividual)
      ..post('/upload/from_url/', _fromUrl)
      ..get('/upload/from_url/status/', _fromUrlStatus);
  }

  final String assets;

  final _uuid = Uuid();

  Future<Response> _base(Request request) async {
    return Response.ok(jsonEncode({'file': _uuid.v4()}),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _multipartStart(Request request) async {
    final origin = request.requestedUri.origin;
    return Response.ok(
        jsonEncode({
          'uuid': _uuid.v4(),
          'parts': [
            '$origin/upload/multipart/1/',
            '$origin/upload/multipart/2/',
            '$origin/upload/multipart/3/',
            '$origin/upload/multipart/4/',
          ]
        }),
        headers: const {'Content-Type': 'application/json'});
  }

  Response _multipartComplete(Request request) {
    return Response.ok(jsonEncode('ok'),
        headers: const {'Content-Type': 'application/json'});
  }

  Response _multipartIndividual(Request request) {
    return Response.ok(jsonEncode({}),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _fromUrl(Request request) async {
    return Response.ok(jsonEncode({'type': 'token', 'token': _uuid.v4()}),
        headers: const {'Content-Type': 'application/json'});
  }

  int _status = 0;

  Future<Response> _fromUrlStatus(Request request) async {
    if (_status == 0) {
      _status++;
      return Response.ok(jsonEncode({'status': 'waiting'}),
          headers: const {'Content-Type': 'application/json'});
    } else if (_status == 1) {
      _status++;
      return Response.ok(
          jsonEncode({'status': 'progress', 'total': 732434, 'done': 134427}),
          headers: const {'Content-Type': 'application/json'});
    }

    final file = File(path.join(assets, 'upload_from_url_success.json'));
    final json = await file.readAsString();

    _status = 0;
    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }
}
