class Movimiento {
  final int id;
  final DateTime fecha;
  final double monto;
  final double montoUYU;
  final String moneda;
  final String descripcion;
  final String tipoMovimiento; // "Entrada" | "Salida"
  final String nombreUsuario;

  final String nombreTipoGasto;
  final String nombreTipoIngreso;

  // ✅ NUEVO (para filtrar bien)
  final int? tipoGastoId;
  final int? tipoIngresoId;

  Movimiento({
    required this.id,
    required this.fecha,
    required this.monto,
    required this.montoUYU,
    required this.moneda,
    required this.descripcion,
    required this.tipoMovimiento,
    required this.nombreUsuario,
    required this.nombreTipoGasto,
    required this.nombreTipoIngreso,
    this.tipoGastoId,
    this.tipoIngresoId,
  });

  bool get esSalida => tipoMovimiento.toLowerCase() == 'salida';
  bool get esEntrada => tipoMovimiento.toLowerCase() == 'entrada';

  String get nombreTipo {
    if (esSalida && nombreTipoGasto != 'NO APLICA') return nombreTipoGasto;
    if (esEntrada && nombreTipoIngreso != 'NO APLICA') return nombreTipoIngreso;
    return '';
  }

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      monto: (json['monto'] as num).toDouble(),
      montoUYU: (json['montoUYU'] as num).toDouble(),
      moneda: json['moneda'],
      descripcion: json['descripcion'] ?? '',
      tipoMovimiento: json['tipoMovimiento'],
      nombreUsuario: json['nombreUsuario'],
      nombreTipoGasto: json['nombreTipoGasto'] ?? 'NO APLICA',
      nombreTipoIngreso: json['nombreTipoIngreso'] ?? 'NO APLICA',

      // ✅ parse de IDs (si vienen null, queda null)
      tipoGastoId: json['tipoGastoId'],
      tipoIngresoId: json['tipoIngresoId'],
    );
  }
}
