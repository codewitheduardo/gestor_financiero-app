import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'username';

  String? token;
  String? username;

  Future<void> load() async {
    token = await _storage.read(key: _tokenKey);
    username = await _storage.read(key: _userKey);
  }

  Future<void> setToken(String value) async {
    token = value;
    await _storage.write(key: _tokenKey, value: value);
  }

  Future<void> setUsername(String value) async {
    username = value;
    await _storage.write(key: _userKey, value: value);
  }

  Future<void> setSession({
    required String token,
    required String username,
  }) async {
    this.token = token;
    this.username = username;

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: username);
  }

  Future<void> clear() async {
    token = null;
    username = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;
}
