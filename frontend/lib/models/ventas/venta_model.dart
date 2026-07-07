class Venta {
  final String? id;
  final String? folio;
  final DateTime fecha;
  final String vendedor;
  final String? vendedorId;
  final String? pacienteId;
  final String? pacienteNombre;
  final String? pacienteTelefono;
  final List<VentaProducto> productos;
  final double subtotal;
  final double descuentoTotal;
  final double total;
  final double anticipo;
  final double saldoPendiente;
  final String formaPago;
  final Map<String, dynamic>? detallePagoMixto;
  final DateTime? fechaEntrega;
  final String estado;
  final List<Map<String, dynamic>> historialEstados;
  final List<Map<String, dynamic>>? historialAbonos;
  final String? notas;

  Venta({
    this.id,
    this.folio,
    required this.fecha,
    required this.vendedor,
    this.vendedorId,
    this.pacienteId,
    this.pacienteNombre,
    this.pacienteTelefono,
    required this.productos,
    required this.subtotal,
    required this.descuentoTotal,
    required this.total,
    required this.anticipo,
    required this.saldoPendiente,
    required this.formaPago,
    this.detallePagoMixto,
    this.fechaEntrega,
    required this.estado,
    required this.historialEstados,
    this.historialAbonos,
    this.notas,
  });

  // Función auxiliar para parsear números (Decimal128 de MongoDB)
static double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  
  // Para Decimal128 de MongoDB
  if (value is Map) {
    if (value['\$numberDecimal'] != null) {
      return double.tryParse(value['\$numberDecimal'].toString()) ?? 0.0;
    }
  }
  
  print('⚠️ _parseDouble - Tipo no manejado: ${value.runtimeType}, valor: $value');
  return 0.0;
}

  // Función auxiliar para parsear fechas
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Venta.fromJson(Map<String, dynamic> json) {
    // Parsear productos
    List<VentaProducto> productos = [];
    if (json['productos'] != null) {
      productos = (json['productos'] as List).map((item) {
        return VentaProducto(
          productoId: item['producto_id'] ?? '',
          tipo: item['tipo'] ?? '',
          nombre: item['nombre'] ?? '',
          codigo: item['codigo'] ?? '',
          cantidad: (item['cantidad'] ?? 0).toInt(),
          precioUnitario: _parseDouble(item['precio_unitario']),
          descuento: _parseDouble(item['descuento']),
          subtotal: _parseDouble(item['subtotal']),
          graduacion: item['graduacion'],
          armazonDetalle: item['armazon_detalle'],
        );
      }).toList();
    }

    // Parsear historial de estados
    List<Map<String, dynamic>> historialEstados = [];
    if (json['historial_estados'] != null) {
      historialEstados = (json['historial_estados'] as List).map((e) => {
        'estado': e['estado'] ?? '',
        'fecha': _parseDate(e['fecha']),
        'nota': e['nota'] ?? '',
        'actualizado_por': e['actualizado_por'] ?? '',
      }).toList();
    }

    // Parsear historial de abonos
    List<Map<String, dynamic>>? historialAbonos;
    if (json['historial_abonos'] != null) {
      historialAbonos = (json['historial_abonos'] as List).map((a) => {
        'monto': _parseDouble(a['monto']),
        'fecha': _parseDate(a['fecha']),
        'forma_pago': a['forma_pago'] ?? 'efectivo',
        'registrado_por': a['registrado_por'] ?? '',
        'nota': a['nota'] ?? '',
      }).toList();
    }

    return Venta(
      id: json['_id'] ?? json['id'],
      folio: json['folio'],
      fecha: _parseDate(json['fecha']),
      vendedor: json['vendedor'] ?? '',
      vendedorId: json['vendedor_id'],
      pacienteId: json['paciente_id'],
      pacienteNombre: json['paciente_nombre'],
      pacienteTelefono: json['paciente_telefono'],
      productos: productos,
      subtotal: _parseDouble(json['subtotal']),
      descuentoTotal: _parseDouble(json['descuento_total']),
      total: _parseDouble(json['total']),
      anticipo: _parseDouble(json['anticipo']),
      saldoPendiente: _parseDouble(json['saldo_pendiente']),
      formaPago: json['forma_pago'] ?? 'efectivo',
      detallePagoMixto: json['detalle_pago_mixto'],
      fechaEntrega: json['fecha_entrega'] != null 
          ? _parseDate(json['fecha_entrega']) 
          : null,
      estado: json['estado'] ?? 'por_enviar',
      historialEstados: historialEstados,
      historialAbonos: historialAbonos,
      notas: json['notas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'vendedor': vendedor,
      'vendedor_id': vendedorId,
      'paciente_id': pacienteId,
      'paciente_nombre': pacienteNombre,
      'paciente_telefono': pacienteTelefono,
      'productos': productos.map((p) => p.toJson()).toList(),
      'subtotal': subtotal,
      'descuento_total': descuentoTotal,
      'total': total,
      'anticipo': anticipo,
      'saldo_pendiente': saldoPendiente,
      'forma_pago': formaPago,
      'detalle_pago_mixto': detallePagoMixto,
      'fecha_entrega': fechaEntrega?.toIso8601String(),
      'estado': estado,
      'historial_estados': historialEstados,
      'notas': notas,
    };
  }
}

class VentaProducto {
  final String productoId;
  final String tipo;
  final String nombre;
  final String codigo;
  final int cantidad;
  final double precioUnitario;
  final double descuento;
  final double subtotal;
  final Map<String, dynamic>? graduacion;
  final Map<String, dynamic>? armazonDetalle;

  VentaProducto({
    required this.productoId,
    required this.tipo,
    required this.nombre,
    required this.codigo,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.subtotal,
    this.graduacion,
    this.armazonDetalle,
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    
    // Para Decimal128 de MongoDB
    if (value is Map) {
      if (value['\$numberDecimal'] != null) {
        return double.tryParse(value['\$numberDecimal'].toString()) ?? 0.0;
      }
    }
    
    return 0.0;
  }

  factory VentaProducto.fromJson(Map<String, dynamic> json) {
    return VentaProducto(
      productoId: json['producto_id'] ?? '',
      tipo: json['tipo'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      cantidad: (json['cantidad'] ?? 0).toInt(),
      precioUnitario: _parseDouble(json['precio_unitario']),
      descuento: _parseDouble(json['descuento']),
      subtotal: _parseDouble(json['subtotal']),
      graduacion: json['graduacion'],
      armazonDetalle: json['armazon_detalle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'tipo': tipo,
      'nombre': nombre,
      'codigo': codigo,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'descuento': descuento,
      'subtotal': subtotal,
      'graduacion': graduacion,
      'armazon_detalle': armazonDetalle,
    };
  }
}


class ItemVenta {
  String productoId;
  String nombre;
  String codigo;
  String tipo;
  double precioUnitario;
  int cantidad;
  double descuento;

  ItemVenta({
    required this.productoId,
    required this.nombre,
    required this.codigo,
    required this.tipo,
    required this.precioUnitario,
    required this.cantidad,
    required this.descuento,
  });

  double get subtotal => (precioUnitario * cantidad) - descuento;

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'nombre': nombre,
      'codigo': codigo,
      'tipo': tipo,
      'precio_unitario': precioUnitario,
      'cantidad': cantidad,
      'descuento': descuento,
      'subtotal': subtotal,
    };
  }

  factory ItemVenta.fromJson(Map<String, dynamic> json) {
    return ItemVenta(
      productoId: json['producto_id'] ?? '',
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      tipo: json['tipo'] ?? '',
      precioUnitario: (json['precio_unitario'] ?? 0).toDouble(),
      cantidad: json['cantidad'] ?? 1,
      descuento: (json['descuento'] ?? 0).toDouble(),
    );
  }
}