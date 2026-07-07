class ResumenVentas {
  final double totalVentas;
  final int cantidadVentas;
  final double efectivo;
  final double tarjeta;
  final double transferencia;
  final double promedioVenta;

  ResumenVentas({
    required this.totalVentas,
    required this.cantidadVentas,
    required this.efectivo,
    required this.tarjeta,
    required this.transferencia,
    required this.promedioVenta,
  });

  factory ResumenVentas.fromJson(Map<String, dynamic> json) {
    return ResumenVentas(
      totalVentas: (json['totalVentas'] ?? 0).toDouble(),
      cantidadVentas: json['cantidadVentas'] ?? 0,
      efectivo: (json['efectivo'] ?? 0).toDouble(),
      tarjeta: (json['tarjeta'] ?? 0).toDouble(),
      transferencia: (json['transferencia'] ?? 0).toDouble(),
      promedioVenta: (json['promedioVenta'] ?? 0).toDouble(),
    );
  }
}