import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/app_exceptions.dart';

class ApiClient {
  final String baseUrl;
  String? token;

  ApiClient({required this.baseUrl, this.token});

  Map<String, String> _headers() {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Future<http.Response> postRaw(String path, Object body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
        body: jsonEncode(body),
      );

      final msg = res.body.isNotEmpty ? res.body : 'Error';

      if (res.statusCode >= 200 && res.statusCode < 300) return res;

      if (res.statusCode == 401) throw UnauthorizedException();
      if (res.statusCode == 409) throw ConflictException(msg);
      if (res.statusCode == 400) throw ValidationException(msg);

      throw ServerException();
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<dynamic> getJson(String path) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
      );
      return _handleJson(res);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<dynamic> postJson(String path, Object body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return _handleJson(res);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<dynamic> putJson(String path, Object body) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return _handleJson(res);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<dynamic> patchJson(String path, Object body) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return _handleJson(res);
    } on SocketException {
      throw NetworkException();
    }
  }

  Future<dynamic> deleteJson(String path) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers(),
      );
      return _handleJson(res);
    } on SocketException {
      throw NetworkException();
    }
  }

  dynamic _handleJson(http.Response res) {
    final msg = res.body.isNotEmpty ? res.body : 'Error';

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      try {
        return jsonDecode(res.body);
      } catch (_) {
        return res.body; // por si viene texto plano
      }
    }

    if (res.statusCode == 401) throw UnauthorizedException();
    if (res.statusCode == 409) throw ConflictException(msg);
    if (res.statusCode == 400) throw ValidationException(msg);

    throw ServerException();
  }
}
