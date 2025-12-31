import '../models/tipo_ingreso.dart';
import 'api_client.dart';

class TipoIngresoService {
  final ApiClient api;
  TipoIngresoService(this.api);

  Future<List<TipoIngreso>> obtenerTodos() async {
    final data = await api.getJson('/api/TipoIngreso/GetAll');
    return (data as List).map((e) => TipoIngreso.fromJson(e)).toList();
  }

  Future<List<TipoIngreso>> obtenerActivos() async {
    final data = await api.getJson('/api/TipoIngreso/GetAllActives');
    return (data as List).map((e) => TipoIngreso.fromJson(e)).toList();
  }

  Future<void> crear(String nombre) async {
    await api.postJson('/api/TipoIngreso/Create', {'nombre': nombre});
  }

  Future<void> editar({
    required int id,
    required String nombre,
    required bool activo,
  }) async {
    await api.patchJson('/api/TipoIngreso/Edit', {
      'id': id,
      'nombre': nombre,
      'activo': activo,
    });
  }

  Future<void> eliminar(int id) async {
    await api.deleteJson('/api/TipoIngreso/Delete/$id');
  }
}
