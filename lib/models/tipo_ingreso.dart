class TipoIngreso {
  final int id;
  final String nombre;
  final bool activo;

  TipoIngreso({required this.id, required this.nombre, required this.activo});

  factory TipoIngreso.fromJson(Map<String, dynamic> json) {
    return TipoIngreso(
      id: json['id'] ?? json['tipoIngresoId'] ?? json['tipoIngresoID'],
      nombre: json['nombre'],
      activo: json['activo'] ?? true,
    );
  }
}
