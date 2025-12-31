import '../models/movimiento.dart';
import 'api_client.dart';

class MovimientoService {
  final ApiClient api;
  MovimientoService(this.api);

  Future<List<Movimiento>> obtenerTodos() async {
    final data = await api.getJson('/api/Movimiento/GetAll');
    return (data as List).map((e) => Movimiento.fromJson(e)).toList();
  }

  Future<List<Movimiento>> obtenerPorMesAnio(int month, int year) async {
    final data = await api.getJson(
      '/api/Movimiento/GetByMonthYear?month=$month&year=$year',
    );
    return (data as List).map((e) => Movimiento.fromJson(e)).toList();
  }

  Future<void> crear({
    required bool esSalida,
    required String moneda,
    required String descripcion,
    required double monto,
    required DateTime fecha,
    int? tipoGastoId,
    int? tipoIngresoId,
  }) async {
    final body = {
      'esSalida': esSalida,
      'moneda': moneda,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'tipoGastoId': esSalida ? tipoGastoId : 0,
      'tipoIngresoId': esSalida ? 0 : tipoIngresoId,
    };

    await api.postJson('/api/Movimiento/Create', body);
  }

  Future<void> eliminar(int id) async {
    await api.deleteJson('/api/Movimiento/Delete/$id');
  }
}
