import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class GroupsRoutes {
  GroupsRoutes(Router router, this.assets) {
    router
      ..get('/groups/', _list)
      ..get('/groups/<groupId>/', _info)
      ..delete('/groups/<groupId>/', _delete)
      ..post('/upload/group/', _create);
  }

  final String assets;

  Future<Response> _list(Request request) async {
    final file = File(path.join(assets, 'group_list.json'));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _info(Request request, String groupId) async {
    final file = File(path.join(assets, 'group_info.json'));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  Future<Response> _create(Request request) async {
    final file = File(path.join(assets, 'group_info.json'));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }

  Response _delete(Request request, String groupId) {
    return Response(204);
  }
}
