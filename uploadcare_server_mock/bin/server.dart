import 'dart:io';

import 'package:path/path.dart' show join;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uploadcare_server_mock/cdn_routes.dart';
import 'package:uploadcare_server_mock/converting_routes.dart';
import 'package:uploadcare_server_mock/file_metadata_routes.dart';
import 'package:uploadcare_server_mock/file_routes.dart';
import 'package:uploadcare_server_mock/groups_routes.dart';
import 'package:uploadcare_server_mock/upload_routes.dart';
import 'package:uploadcare_server_mock/version_middleware.dart';
import 'package:uploadcare_server_mock/webhooks_routes.dart';

final _assetsDir = join(Directory.current.path, 'assets');

// Configure routes.
final _router = Router();

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  FileRoutes(_router, _assetsDir);
  CdnRoutes(_router, _assetsDir);
  WebhooksRoutes(_router, _assetsDir);
  GroupsRoutes(_router, _assetsDir);
  ConvertingRoutes(_router, _assetsDir);
  FileMetadataRoutes(_router);
  UploadRoutes(_router);

  // Configure a pipeline that logs requests.
  final handler = (!args.contains('--disable-logs')
          ? Pipeline()
              .addMiddleware(logRequests().addMiddleware(versionMiddleware()))
          : Pipeline().addMiddleware(versionMiddleware()))
      .addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
