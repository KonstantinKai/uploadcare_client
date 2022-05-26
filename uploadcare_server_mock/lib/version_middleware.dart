import 'package:shelf/shelf.dart';

Middleware versionMiddleware() => (innerHandler) => (request) {
      final match =
          RegExp(r'(v\d+\.\d+)').firstMatch(request.headers['accept'] ?? '');

      Request modRequest = request;

      if (match != null) {
        modRequest = request.change(context: {
          ...request.context,
          'version': match[1]!,
        });
      }

      return Future.sync(() => innerHandler(modRequest)).then((response) {
        return response;
      }, onError: (Object error, StackTrace stackTrace) {
        throw error;
      });
    };
