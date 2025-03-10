import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'utils.dart';

class FileRoutes {
  FileRoutes(Router router, this.assets) {
    router
      ..get('/files/', _files)
      ..get('/files/<fileId>/', _fileInfo)
      ..delete('/files/storage/', _filesDelete)
      ..get('/fakefile/<filename>', _fakeFile)
      ..get('/files/<fileId>/appdata/', _appData)
      ..get('/files/<fileId>/appdata/<appName>/', _appDataByAppName)
      ..post('/files/local_copy/', _localCopy)
      ..post('/files/remote_copy/', _remoteCopy);
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
    final include =
        request.requestedUri.queryParameters['include']?.split(',') ?? [];

    final (String, Response?) res = switch (fileId) {
      '7ed2aed0-0482-4c13-921b-0557b193edc2' => (
          'file_info_video_$version.json',
          null
        ),
      'file-with-aws-recognition' => !include.contains('appdata')
          ? ('', Response.badRequest())
          : ('file_info_appdata_aws_recognition.json', null),
      'file-with-aws-recognition-moderation' => !include.contains('appdata')
          ? ('', Response.badRequest())
          : ('file_info_appdata_aws_recognition_moderation.json', null),
      'file-with-clamav' => !include.contains('appdata')
          ? ('', Response.badRequest())
          : ('file_info_appdata_clamav.json', null),
      'file-with-removebg' => !include.contains('appdata')
          ? ('', Response.badRequest())
          : ('file_info_appdata_remove_bg.json', null),
      _ => ('file_info_image_$version.json', null),
    };

    final (filename, bad) = res;

    if (bad != null) {
      return bad;
    }

    final file = File(path.join(assets, filename));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _filesDelete(Request request) async {
    final payload = await Utils.parseJsonBodyAsList(request);

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

  Future<Response> _appData(Request request, String fileId) async {
    final file = File(path.join(assets, 'file_application_data.json'));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _appDataByAppName(
      Request request, String fileId, String appName) async {
    final file = File(path.join(assets, 'file_application_data.json'));
    final json = await file.readAsString();

    Map<String, dynamic> result = jsonDecode(json);

    if (!result.containsKey(appName)) {
      return Response.notFound(appName);
    }

    result = result[appName];

    return Response.ok(jsonEncode(result),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _localCopy(Request request) async {
    final file = File(path.join(assets, 'file_local_copy.json'));
    final json = await file.readAsString();
    final payload = await Utils.parseJsonBodyAsMap(request);

    if (payload['source'] == null) {
      return Response.badRequest(body: 'source is empty');
    }

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _remoteCopy(Request request) async {
    final payload = await Utils.parseJsonBodyAsMap(request);

    if (payload['source'] == null) {
      return Response.badRequest(body: 'source is empty');
    }

    if (payload['target'] == null) {
      return Response.badRequest(body: 'target is empty');
    }

    return Response.ok(
        jsonEncode({
          'type': 'url',
          'result':
              's3://mybucket/03ccf9ab-f266-43fb-973d-a6529c55c2ae/image.png'
        }),
        headers: const {'Content-Type': 'application/json'});
  }
}
