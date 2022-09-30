import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uploadcare_server_mock/utils.dart';

class AddonsRoutes {
  AddonsRoutes(Router router, this.assets) {
    router
      ..post('/addons/aws_rekognition_detect_labels/execute/',
          _executeAwsRecognition)
      ..get('/addons/aws_rekognition_detect_labels/execute/status/',
          _statusAwsRecognition)
      ..post('/addons/uc_clamav_virus_scan/execute/', _executeClamAV)
      ..get('/addons/uc_clamav_virus_scan/execute/status/', _statusClamAV)
      ..post('/addons/remove_bg/execute/', _executeRemoveBg)
      ..get('/addons/remove_bg/execute/status/', _statusRemoveBg);
  }

  final String assets;

  Future<Response> _defExecuteResponse(
      Request request, Map<String, dynamic> params) async {
    if (!params.containsKey('target')) {
      return Response.badRequest();
    }

    return Response.ok(
        jsonEncode({
          'request_id': '8db3c8b4-2dea-4146-bcdb-63387e2b33c1',
        }),
        headers: const {'Content-Type': 'application/json'});
  }

  // Future<Map<String, dynamic>> _parseParams(Request request) async {
  //   final bodyAsString = await request.readAsString();
  //   final payload = jsonDecode(bodyAsString) as Map<String, dynamic>;

  //   return payload;
  // }

  Response _status(
    Map<String, Object> result,
  ) {
    return Response.ok(jsonEncode(result),
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _executeAwsRecognition(Request request) async {
    return _defExecuteResponse(
        request, await Utils.parseJsonBodyAsMap(request));
  }

  int _awsCount = 0;
  Future<Response> _statusAwsRecognition(Request request) async {
    if (_awsCount == 0) {
      _awsCount++;
      return _status({
        'status': 'in_progress',
      });
    }

    _awsCount = 0;
    return _status(
        {'status': request.requestedUri.queryParameters['request_id']!});
  }

  Future<Response> _executeClamAV(Request request) async {
    final payload = await Utils.parseJsonBodyAsMap(request);

    if (payload['params']?['purge_infected'] != null) {
      if (!['true', 'false'].contains(payload['params']['purge_infected'])) {
        return Response.badRequest();
      }
    }

    return _defExecuteResponse(request, payload);
  }

  int _clamAVCount = 0;
  Future<Response> _statusClamAV(Request request) async {
    if (_clamAVCount == 0) {
      _clamAVCount++;
      return _status({
        'status': 'in_progress',
      });
    }

    _clamAVCount = 0;
    return _status(
        {'status': request.requestedUri.queryParameters['request_id']!});
  }

  Future<Response> _executeRemoveBg(Request request) async {
    final payload = await Utils.parseJsonBodyAsMap(request);

    if (payload['params']?['crop]'] != null) {
      if (!['true', 'false'].contains(payload['params']?['crop]'])) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['crop_margin]'] != null) {
      if (payload['params']['crop_margin]'] is! String) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['scale]'] != null) {
      if (payload['params']['scale]'] is! String) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['add_shadow]'] != null) {
      if (!['true', 'false'].contains(payload['params']['add_shadow]'])) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['type_level]'] != null) {
      if (payload['params']['type_level]'] is! String) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['level]'] != null) {
      if (payload['params']['level]'] is! String) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['semitransparency]'] != null) {
      if (!['true', 'false'].contains(payload['params']['semitransparency]'])) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['channels]'] != null) {
      if (payload['params']['channels]'] is! String) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['roi]'] != null) {
      if (payload['params']['roi]'] is! String) {
        return Response.badRequest();
      }
    }

    if (payload['params']?['position]'] != null) {
      if (payload['params']['position]'] is! String) {
        return Response.badRequest();
      }
    }

    return _defExecuteResponse(request, payload);
  }

  int _remoBgCount = 0;
  Future<Response> _statusRemoveBg(Request request) async {
    if (_remoBgCount == 0) {
      _remoBgCount++;
      return _status({
        'status': 'in_progress',
      });
    }

    _remoBgCount = 0;
    return _status({
      'status': request.requestedUri.queryParameters['request_id']!,
      'result': {'file_id': '2db7c8b4-24ea-4246-bfdb-73387e2b33c2'},
    });
  }
}
