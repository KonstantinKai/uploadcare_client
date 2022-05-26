import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

class UploadRoutes {
  UploadRoutes(Router router) {
    router
      ..post('/upload/base/', _base)
      ..post('/upload/multipart/start/', _multipartStart)
      ..post('/upload/multipart/complete/', _multipartComplete)
      ..put('/upload/multipart/<individualFile>/', _multipartIndividual)
      ..post('/upload/from_url/', _fromUrl)
      ..get('/upload/from_url/status/', _fromUrlStatus);
  }

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

  Response _fromUrlStatus(Request request) {
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

    _status = 0;
    return Response.ok(
        jsonEncode({
          'status': 'success',
          'uuid': 'be3b4d5e-179d-460e-8a5d-69112ac86cbb',
          'file_id': 'be3b4d5e-179d-460e-8a5d-69112ac86cbb',
          'size': 2667636,
          'total': 2667636,
          'done': 2667636,
          'original_filename': 'IMG-0412_123.JPG',
          'filename': 'IMG0412_123.JPG',
          'mime_type': 'image/jpeg',
          'image_info': {
            'color_mode': 'RGB',
            'orientation': 6,
            'format': 'JPEG',
            'height': 4032,
            'width': 3024,
            'sequence': false,
            'geo_location': {
              'latitude': 55.62013611111111,
              'longitude': 37.66299166666666
            },
            'datetime_original': '2018-08-20T08:59:50',
            'dpi': [72, 72]
          },
          'video_info': null,
          'content_info': {
            'mime': {'mime': 'image/jpeg', 'type': 'image', 'subtype': 'jpeg'},
            'image': {
              'color_mode': 'RGB',
              'orientation': 6,
              'format': 'JPEG',
              'height': 4032,
              'width': 3024,
              'sequence': false,
              'geo_location': {
                'latitude': 55.62013611111111,
                'longitude': 37.66299166666666
              },
              'datetime_original': '2018-08-20T08:59:50',
              'dpi': [72, 72]
            }
          },
          'metadata': {'subsystem': 'uploader', 'pet': 'cat'},
          'is_image': true,
          'is_stored': true,
          'is_ready': true
        }),
        headers: const {'Content-Type': 'application/json'});
  }
}
