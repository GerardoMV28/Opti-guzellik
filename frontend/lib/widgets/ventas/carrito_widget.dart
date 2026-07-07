import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/ventas/venta_model.dart';

class CarritoWidget extends StatelessWidget {
  final ItemVenta item;
  final int stockMaximo;
  final Function(int) onCantidadChanged;
  final VoidCallback onEliminar;
  final VoidCallback onEditarDescuento;

  const CarritoWidget({
    Key? key,
    required this.item,
    required this.stockMaximo,
    required this.onCantidadChanged,
    required this.onEliminar,
    required this.onEditarDescuento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool puedeSumar = item.cantidad < stockMaximo;
    final bool puedeRestar = item.cantidad > 1;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono del producto
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getColorForTipo(item.tipo).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForTipo(item.tipo),
              color: _getColorForTipo(item.tipo),
            ),
          ),
          SizedBox(width: 12),
          
          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '\$${item.precioUnitario.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.azulReal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.descuento > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'Descuento: -\$${item.descuento.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 11, color: Colors.green[700]),
                    ),
                  ),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onEditarDescuento,
                    icon: Icon(Icons.local_offer_outlined, size: 16, color: AppColors.turquesa),
                    label: Text(
                      item.descuento > 0 ? 'Cambiar descuento' : 'Aplicar descuento',
                      style: TextStyle(fontSize: 12, color: AppColors.turquesa),
                    ),
                  ),
                ),
                // Indicador de stock restante
                if (stockMaximo < 10)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Stock disponible: $stockMaximo',
                      style: TextStyle(
                        fontSize: 10,
                        color: stockMaximo <= 2 ? Colors.red : Colors.orange,
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                Row(
                  children: [
                    // Botón restar
                    InkWell(
                      onTap: puedeRestar 
                          ? () => onCantidadChanged(item.cantidad - 1)
                          : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: puedeRestar 
                              ? Colors.grey[200] 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.remove, 
                          size: 18,
                          color: puedeRestar 
                              ? Colors.black87 
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      child: Text(
                        '${item.cantidad}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.cantidad == stockMaximo 
                              ? Colors.red 
                              : Colors.black87,
                        ),
                      ),
                    ),
                    // Botón sumar
                    InkWell(
                      onTap: puedeSumar 
                          ? () => onCantidadChanged(item.cantidad + 1)
                          : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: puedeSumar 
                              ? Colors.grey[200] 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.add, 
                          size: 18,
                          color: puedeSumar 
                              ? Colors.black87 
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Precio total y eliminar
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.azulReal,
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: onEliminar,
                child: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForTipo(String tipo) {
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

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'armazon':
        return Colors.blue;
      case 'mica':
        return Colors.green;
      case 'lente_contacto':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }
}