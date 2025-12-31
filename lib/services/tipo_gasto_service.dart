import '../models/tipo_gasto.dart';
import 'api_client.dart';

class TipoGastoService {
  final ApiClient api;
  TipoGastoService(this.api);

  Future<List<TipoGasto>> obtenerTodos() async {
    final data = await api.getJson('/api/TipoGasto/GetAll');
    return (data as List).map((e) => TipoGasto.fromJson(e)).toList();
  }

  Future<List<TipoGasto>> obtenerActivos() async {
    final data = await api.getJson('/api/TipoGasto/GetAllActives');
    return (data as List).map((e) => TipoGasto.fromJson(e)).toList();
  }

  Future<void> crear(String nombre) async {
    await api.postJson('/api/TipoGasto/Create', {'nombre': nombre});
  }

  Future<void> editar({
    required int id,
    required String nombre,
    required bool activo,
  }) async {
    await api.patchJson('/api/TipoGasto/Edit', {
      'id': id,
      'nombre': nombre,
      'activo': activo,
    });
  }

  Future<void> eliminar(int id) async {
    await api.deleteJson('/api/TipoGasto/Delete/$id');
  }
}
