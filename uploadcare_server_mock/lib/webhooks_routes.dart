import 'dart:convert';
import 'dart:io';

import 'package:shelf_multipart/form_data.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class WebhooksRoutes {
  WebhooksRoutes(Router router, this.assets) {
    router
      ..get('/webhooks/', _list)
      ..post('/webhooks/', _create)
      ..put('/webhooks/<hookId>/', _update)
      ..delete('/webhooks/unsubscribe/', _delete);
  }

  final String assets;

  Future<Response> _list(Request request) async {
    final file = File(path.join(assets, 'webhooks_list.json'));
    final json = await file.readAsString();

    return Response.ok(
      json,
      headers: const {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _create(Request request) async {
    final payload = <String, String>{
      await for (final formData in request.multipartFormData)
        formData.name: await formData.part.readString(),
    };

    return Response.ok(
      jsonEncode({
        'id': 1,
        'project': 13,
        'created': '2016-04-27T11:49:54.948615Z',
        'updated': '2016-04-27T12:04:57.819933Z',
        'event': payload['event'],
        'target_url': payload['target_url'],
        'version': payload['version'] ?? '0.6',
        if (payload['is_active'] != null) 'is_active': payload['is_active'],
        if (payload['signing_secret'] != null)
          'signing_secret': payload['signing_secret'],
      }),
      headers: const {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _update(Request request, String hookId) async {
    final payload = <String, String>{
      await for (final formData in request.multipartFormData)
        formData.name: await formData.part.readString(),
    };

    return Response.ok(
      jsonEncode({
        'id': hookId,
        'project': 13,
        'created': '2016-04-27T11:49:54.948615Z',
        'updated': '2016-04-27T12:04:57.819933Z',
        'event': payload['event'],
        'target_url': payload['target_url'],
        'version': payload['version'] ?? '0.6',
        if (payload['is_active'] != null) 'is_active': payload['is_active'],
        if (payload['signing_secret'] != null)
          'signing_secret': payload['signing_secret'],
      }),
      headers: const {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _delete(Request request) async {
    final payload = <String, String>{
      await for (final formData in request.multipartFormData)
        formData.name: await formData.part.readString(),
    };

    if ((payload['target_url'] ?? '').isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'detail': '`target_url` is missing'}),
        headers: const {'Content-Type': 'application/json'},
      );
    }

    return Response(204);
  }
}
