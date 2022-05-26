import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ConvertingRoutes {
  ConvertingRoutes(Router router, this.assets) {
    router
      ..post('/convert/video/', _convert)
      ..post('/convert/document/', _convert)
      ..get('/convert/video/status/<token>/', _status)
      ..get('/convert/document/status/<token>/', _status);
  }

  final String assets;

  Future<Response> _convert(Request requets) async {
    final type = requets.url.path.contains('/video/') ? 'video' : 'document';
    final file = File(path.join(assets, '${type}_convert.json'));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  int _count = 0;
  Future<Response> _status(Request requets, String token) async {
    final isVideo = requets.url.path.contains('/video/');
    if (_count == 0) {
      _count++;
      return Response.ok(jsonEncode({'status': 'pending'}),
          headers: const {'Content-Type': 'application/json'});
    } else if (_count == 1) {
      _count++;
      return Response.ok(
          jsonEncode({
            'status': 'processing',
            'error': null,
            'result': {
              'uuid': '500196bc-9da5-4aaf-8f3e-70a4ce86edae',
              if (isVideo)
                'thumbnails_group_uuid':
                    '575ed4e8-f4e8-4c14-a58b-1527b6d9ee46~1',
            }
          }),
          headers: const {'Content-Type': 'application/json'});
    }

    _count = 0;
    return Response.ok(
        jsonEncode({
          'status': 'finished',
          'error': null,
          'result': {
            'uuid': '500196bc-9da5-4aaf-8f3e-70a4ce86edae',
            if (isVideo)
              'thumbnails_group_uuid': '575ed4e8-f4e8-4c14-a58b-1527b6d9ee46~1',
          }
        }),
        headers: const {'Content-Type': 'application/json'});
  }
}
