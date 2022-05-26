import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class CdnRoutes {
  CdnRoutes(Router router, this.assets) {
    router.get('/cdn/<fileId>/detect_faces/', _detectFaces);
  }

  final String assets;

  Future<Response> _detectFaces(Request request) async {
    final file = File(path.join(assets, 'detect_faces.json'));
    final json = await file.readAsString();

    return Response.ok(json,
        headers: const {'Content-Type': 'application/json'});
  }
}
