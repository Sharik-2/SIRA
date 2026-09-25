class Ciudad {
  final String departamento;
  final String codigo;
  final String nombre;

  const Ciudad({
    required this.departamento,
    required this.codigo,
    required this.nombre,
  });

  factory Ciudad.fromMap(Map<String, dynamic> map) => Ciudad(
        departamento: map['departamento']?.toString().trim() ?? '',
        codigo: map['codigo']?.toString().trim() ?? '',
        nombre: map['nombre']?.toString() ?? '',
      );
}
