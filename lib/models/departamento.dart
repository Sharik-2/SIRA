class Departamento {
  final String codigo;
  final String nombre;

  const Departamento({required this.codigo, required this.nombre});

  factory Departamento.fromMap(Map<String, dynamic> map) => Departamento(
        codigo: map['codigo']?.toString().trim() ?? '',
        nombre: map['nombre']?.toString() ?? '',
      );
}
