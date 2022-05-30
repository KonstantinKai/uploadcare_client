import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ProjectRoutes {
  ProjectRoutes(Router router, this.assets) {
    router.get('/project/', _info);
  }

  final String assets;

  Future<Response> _info(Request request) async {
    final pubKey = request.context['pub_key']!;
    final file = File(path.join(assets, 'project_info_$pubKey.json'));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }
}
