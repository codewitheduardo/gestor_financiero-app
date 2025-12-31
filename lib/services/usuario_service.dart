import '../errors/app_exceptions.dart';
import 'api_client.dart';

class UsuarioService {
  final ApiClient api;

  UsuarioService(this.api);

  Future<void> crearUsuario(String nombreUsuario, String contrasena) async {
    try {
      await api.postRaw('/api/Usuario/Create', {
        'nombreUsuario': nombreUsuario,
        'contrasena': contrasena,
      });
    } on AppException {
      rethrow;
    } catch (_) {
      throw ServerException();
    }
  }
}
