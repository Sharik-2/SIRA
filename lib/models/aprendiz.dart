class Aprendiz {
  final int? id;
  final String nombre1;
  final String? nombre2;
  final String apellido1;
  final String? apellido2;
  final String celular;
  final String email;
  final String departamento;
  final String ciudad;

  const Aprendiz({
    this.id,
    required this.nombre1,
    this.nombre2,
    required this.apellido1,
    this.apellido2,
    required this.celular,
    required this.email,
    required this.departamento,
    required this.ciudad,
  });

  factory Aprendiz.fromMap(Map<String, dynamic> map) => Aprendiz(
        id: map['id'] as int?,
        nombre1: map['nombre1']?.toString() ?? '',
        nombre2: map['nombre2']?.toString(),
        apellido1: map['apellido1']?.toString() ?? '',
        apellido2: map['apellido2']?.toString(),
        celular: map['celular']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        departamento: map['departamento']?.toString().trim() ?? '',
        ciudad: map['ciudad']?.toString().trim() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'nombre1': nombre1.trim(),
        'nombre2': _nullable(nombre2),
        'apellido1': apellido1.trim(),
        'apellido2': _nullable(apellido2),
        'celular': celular.trim(),
        'email': email.trim(),
        'departamento': departamento.trim(),
        'ciudad': ciudad.trim(),
      };

  static String? _nullable(String? value) {
    final v = value?.trim();
    return v == null || v.isEmpty ? null : v;
  }
}
