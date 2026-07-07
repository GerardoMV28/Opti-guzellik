class Empleado {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String telefono;
  final bool activo;
  final DateTime fechaRegistro;

  Empleado({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.telefono,
    required this.activo,
    required this.fechaRegistro,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['_id'] ?? json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'empleado',
      telefono: json['telefono'] ?? '',
      activo: json['activo'] ?? true,
      fechaRegistro: json['fecha_registro'] != null 
          ? DateTime.parse(json['fecha_registro']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'telefono': telefono,
      'activo': activo,
    };
  }
}