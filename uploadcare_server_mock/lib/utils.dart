import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/form_data.dart';

class Utils {
  static Future<Map<String, dynamic>> parseJsonBodyAsMap(
      Request request) async {
    final bodyAsString = await request.readAsString();
    return jsonDecode(bodyAsString) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> parseJsonBodyAsList(Request request) async {
    final bodyAsString = await request.readAsString();
    return jsonDecode(bodyAsString) as List<dynamic>;
  }

  static Future<String> parseJsonBodyAsString(Request request) async {
    final bodyAsString = await request.readAsString();
    return jsonDecode(bodyAsString) as String;
  }

  static Future<Map<String, String>> parseMultipartBody(Request request) async {
    return <String, String>{
      await for (final formData in request.multipartFormData)
        formData.name: await formData.part.readString(),
    };
  }
}
