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
      ..post('/upload-retry/base/', _baseRetry)
      ..post('/upload-always-fail/base/', _baseAlwaysFail)
      ..post('/upload/multipart/start/', _multipartStart)
      ..post('/upload-retry/multipart/start/', _multipartStartRetry)
      ..post('/upload/multipart/complete/', _multipartComplete)
      ..post('/upload-retry/multipart/complete/', _multipartComplete)
      ..put('/upload/multipart/<individualFile>/', _multipartIndividual)
      ..put('/upload-retry/multipart/<individualFile>/',
          _multipartIndividualRetry)
      ..post('/upload/from_url/', _fromUrl)
      ..get('/upload/from_url/status/', _fromUrlStatus)
      ..post('/upload/retry/reset/', _resetRetryCounters);
  }

  final String assets;

  final _uuid = Uuid();

  // Retry counters for testing
  int _baseRetryCount = 0;
  int _multipartStartRetryCount = 0;
  final Map<String, int> _multipartChunkRetryCount = {};

  Future<Response> _resetRetryCounters(Request request) async {
    _baseRetryCount = 0;
    _multipartStartRetryCount = 0;
    _multipartChunkRetryCount.clear();
    return Response.ok(jsonEncode({'status': 'reset'}),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _baseRetry(Request request) async {
    _baseRetryCount++;
    // Fail first 2 attempts, succeed on 3rd
    if (_baseRetryCount < 3) {
      return Response.internalServerError(
          body: jsonEncode({'error': 'Transient failure $_baseRetryCount'}),
          headers: const {'Content-Type': 'application/json'});
    }
    _baseRetryCount = 0;
    return Response.ok(jsonEncode({'file': _uuid.v4()}),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _baseAlwaysFail(Request request) async {
    return Response.internalServerError(
        body: jsonEncode({'error': 'Always fails'}),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _multipartStartRetry(Request request) async {
    // Start transaction succeeds, but returns URLs that will fail first attempt
    final origin = request.requestedUri.origin;
    return Response.ok(
        jsonEncode({
          'uuid': _uuid.v4(),
          'parts': [
            '$origin/upload-retry/multipart/1/',
            '$origin/upload-retry/multipart/2/',
            '$origin/upload-retry/multipart/3/',
            '$origin/upload-retry/multipart/4/',
          ]
        }),
        headers: const {'Content-Type': 'application/json'});
  }

  Response _multipartIndividualRetry(Request request, String individualFile) {
    final count = _multipartChunkRetryCount[individualFile] ?? 0;
    _multipartChunkRetryCount[individualFile] = count + 1;
    // Fail first attempt for each chunk, succeed on 2nd
    if (count < 1) {
      return Response.internalServerError(
          body:
              jsonEncode({'error': 'Chunk $individualFile transient failure'}),
          headers: const {'Content-Type': 'application/json'});
    }
    return Response.ok(jsonEncode({}),
        headers: const {'Content-Type': 'application/json'});
  }

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
