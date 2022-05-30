import 'package:shelf/shelf.dart';

Middleware versionMiddleware() => (innerHandler) => (request) {
      final versionMatch =
          RegExp(r'(v\d+\.\d+)').firstMatch(request.headers['accept'] ?? '');
      final pubKeyMatch = RegExp(r'Uploadcare.Simple\s(\w+):\w+')
          .firstMatch(request.headers['authorization'] ?? '');

      Request modRequest = request;

      if (versionMatch != null) {
        modRequest = request.change(context: {
          ...request.context,
          'version': versionMatch[1]!,
        });
      }

      if (pubKeyMatch != null) {
        modRequest = modRequest.change(context: {
          ...modRequest.context,
          'pub_key': pubKeyMatch[1]!,
        });
      }

      return Future.sync(() => innerHandler(modRequest)).then((response) {
        return response;
      }, onError: (Object error, StackTrace stackTrace) {
        throw error;
      });
    };
