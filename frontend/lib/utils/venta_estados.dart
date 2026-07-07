import 'package:flutter/material.dart';

/// Etiquetas y colores para `Venta.estado` (alineado con backend `Venta.js`).
class VentaEstados {
  VentaEstados._();

  static String etiqueta(String? estado) {
    switch (estado) {
      case 'por_enviar':
        return 'Por enviar';
      case 'laboratorio':
        return 'En laboratorio';
      case 'garantia':
        return 'Garantía';
      case 'cortesia':
        return 'Cortesía';
      case 'reproceso':
        return 'Reproceso';
      case 'listo_entrega':
        return 'Listo para entrega';
      case 'entregado':
        return 'Entregado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado ?? '—';
    }
  }

  static Color color(String? estado) {
    switch (estado) {
      case 'por_enviar':
        return Colors.orange;
      case 'laboratorio':
        return Colors.blue;
      case 'garantia':
        return Colors.teal;
      case 'cortesia':
        return Colors.pink;
      case 'reproceso':
        return Colors.deepOrange;
      case 'listo_entrega':
        return Colors.green;
      case 'entregado':
        return Colors.purple;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Si la venta queda liquidada: flujo normal pasa a listo para entrega;
  /// se respetan garantía, cortesía, reproceso y listo_entrega explícitos.
  static String alLiquidar(String seleccionado) {
    if (seleccionado == 'por_enviar' || seleccionado == 'laboratorio') {
      return 'listo_entrega';
    }
    return seleccionado;
  }
}
