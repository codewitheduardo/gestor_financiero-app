import 'dart:convert';
import 'dart:io';
import '../errors/app_exceptions.dart';
import '../services/api_client.dart';

class AuthService {
  final ApiClient api;
  AuthService(this.api);

  Future<String> login(String usuario, String contrasena) async {
    try {
      final res = await api.postRaw('/api/auth/login', {
        'nombreUsuario': usuario,
        'contrasena': contrasena,
      });

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['token'];
    } on UnauthorizedException {
      rethrow; // 👈 IMPORTANTÍSIMO
    } on SocketException {
      throw NetworkException();
    } catch (_) {
      throw UnknownException();
    }
  }
}
