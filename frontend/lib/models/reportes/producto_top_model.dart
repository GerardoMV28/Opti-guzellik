class ProductoTop {
  final String id;
  final String nombre;
  final int cantidadVendida;
  final double totalVendido;
  final String tipo;

  ProductoTop({
    required this.id,
    required this.nombre,
    required this.cantidadVendida,
    required this.totalVendido,
    required this.tipo,
  });

  factory ProductoTop.fromJson(Map<String, dynamic> json) {
    return ProductoTop(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      cantidadVendida: json['cantidad'] ?? 0,
      totalVendido: (json['total'] ?? 0).toDouble(),
      tipo: json['tipo'] ?? 'producto',
    );
  }
}