class VentaReporte {
  final String id;
  final DateTime fecha;
  final String vendedor;
  final double total;
  final int cantidadProductos;
  final String formaPago;

  VentaReporte({
    required this.id,
    required this.fecha,
    required this.vendedor,
    required this.total,
    required this.cantidadProductos,
    required this.formaPago,
  });

  factory VentaReporte.fromJson(Map<String, dynamic> json) {
    // Función auxiliar para parsear fechas
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return VentaReporte(
      id: json['_id'] ?? '',
      fecha: _parseDate(json['fecha']),
      vendedor: json['vendedor'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      cantidadProductos: json['cantidadProductos'] ?? 0,
      formaPago: json['forma_pago'] ?? 'efectivo',
    );
  }
}