import 'package:flutter/material.dart';
import '../../models/productos/producto_model.dart';
import '../../utils/colors.dart';

/// Tarjeta de producto en el punto de venta (grid).
/// [compact] reduce iconos y tipografía (p. ej. lista por tipo).
class ProductoPosCard extends StatelessWidget {
  final Producto producto;
  final int cantidadEnCarrito;
  final VoidCallback? onTap;
  final bool compact;

  const ProductoPosCard({
    Key? key,
    required this.producto,
    required this.cantidadEnCarrito,
    required this.onTap,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stockRestante = producto.stock - cantidadEnCarrito;
    final sinStock = stockRestante <= 0;

    final double iconAreaH = compact ? 64 : 100;
    final double iconSize = compact ? 30 : 48;
    final EdgeInsets pad = compact ? EdgeInsets.all(8) : EdgeInsets.all(12);
    final double titleSize = compact ? 12.5 : 14;
    final double codigoSize = compact ? 10.5 : 12;
    final double precioSize = compact ? 14 : 16;
    final double stockFont = compact ? 9 : 10;
    final double stockIcon = compact ? 11 : 12;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: sinStock ? 0.6 : 1.0,
          child: Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: iconAreaH,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: producto.colorTipo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _iconForTipo(producto.tipo),
                      size: iconSize,
                      color: producto.colorTipo,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                Text(
                  producto.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  producto.codigo,
                  style: TextStyle(fontSize: codigoSize, color: Colors.grey[600]),
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  '\$${producto.precioVenta.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: precioSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: compact ? 6 : 8),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: sinStock
                        ? Colors.red.withOpacity(0.2)
                        : (producto.stock <= producto.stockMinimo
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sinStock ? Icons.block : Icons.inventory,
                        size: stockIcon,
                        color: sinStock
                            ? Colors.red
                            : (producto.stock <= producto.stockMinimo
                                ? Colors.orange
                                : Colors.green),
                      ),
                      SizedBox(width: 3),
                      Text(
                        sinStock ? 'Sin stock' : 'Stock: $stockRestante',
                        style: TextStyle(
                          fontSize: stockFont,
                          color: sinStock
                              ? Colors.red
                              : (producto.stock <= producto.stockMinimo
                                  ? Colors.orange
                                  : Colors.green),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'armazon':
        return Icons.visibility;
      case 'mica':
        return Icons.lens;
      case 'lente_contacto':
        return Icons.contactless;
      default:
        return Icons.shopping_bag;
    }
  }
}
