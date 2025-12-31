class TipoGasto {
  final int id;
  final String nombre;
  final bool activo;

  TipoGasto({required this.id, required this.nombre, required this.activo});

  factory TipoGasto.fromJson(Map<String, dynamic> json) {
    return TipoGasto(
      id: json['id'] ?? json['tipoGastoId'] ?? json['tipoGastoID'],
      nombre: json['nombre'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toCreateJson() => {'nombre': nombre};

  Map<String, dynamic> toUpdateJson() => {
    'id': id,
    'nombre': nombre,
    'activo': activo,
  };
}
