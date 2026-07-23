import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../models/productos/producto_model.dart';
import '../../../models/ventas/venta_model.dart';
import '../../../utils/colors.dart';
import '../../../widgets/ventas/producto_pos_card.dart';

/// Lista filtrada por tipo de producto (navegación desde el hub del POS).
class VentasListaTipoScreen extends StatefulWidget {
  final String tipo;
  final List<Producto> productos;
  final ValueListenable<int> carritoVersion;
  final List<ItemVenta> carrito;
  final void Function(Producto) onAgregarAlCarrito;

  const VentasListaTipoScreen({
    Key? key,
    required this.tipo,
    required this.productos,
    required this.carritoVersion,
    required this.carrito,
    required this.onAgregarAlCarrito,
  }) : super(key: key);

  @override
  State<VentasListaTipoScreen> createState() => _VentasListaTipoScreenState();
}

class _VentasListaTipoScreenState extends State<VentasListaTipoScreen> {
  String _busqueda = '';

  String _tipoTitulo(String t) {
    switch (t) {
      case 'armazon':
        return 'Armazones';
      case 'mica':
        return 'Micas';
      case 'lente_contacto':
        return 'Lentes de contacto';
      case 'accesorio':
        return 'Accesorios';
      default:
        return t;
    }
  }

  int _cantidadEnCarrito(Producto p) {
    final i = widget.carrito.indexWhere((e) => e.productoId == p.id);
    if (i == -1) return 0;
    return widget.carrito[i].cantidad;
  }

  List<Producto> get _filtrados {
    if (_busqueda.trim().isEmpty) return widget.productos;
    final q = _busqueda.toLowerCase().trim();
    return widget.productos.where((p) {
      return p.nombre.toLowerCase().contains(q) ||
          p.codigo.toLowerCase().contains(q) ||
          p.marca.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.carritoVersion,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(decoration: BoxDecoration(gradient: AppColors.appBarGradient)),
            foregroundColor: Colors.white,
            title: Text(_tipoTitulo(widget.tipo)),
          ),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar en este tipo...',
                    prefixIcon: Icon(Icons.search, color: AppColors.azulCobalto),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
              Expanded(
                child: _filtrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 56, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              widget.productos.isEmpty
                                  ? 'No hay productos de este tipo con stock'
                                  : 'Ningún resultado para la búsqueda',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final cross = w > 1050
                              ? 5
                              : w > 700
                                  ? 4
                                  : w > 440
                                      ? 3
                                      : 2;
                          final aspect = cross >= 5
                              ? 0.78
                              : cross == 4
                                  ? 0.82
                                  : cross == 3
                                      ? 0.88
                                      : 0.95;

                          return GridView.builder(
                            padding: EdgeInsets.all(12),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cross,
                              childAspectRatio: aspect,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _filtrados.length,
                            itemBuilder: (context, index) {
                              final producto = _filtrados[index];
                              final qty = _cantidadEnCarrito(producto);
                              final stockRestante = producto.stock - qty;
                              final sinStock = stockRestante <= 0;
                              return ProductoPosCard(
                                producto: producto,
                                cantidadEnCarrito: qty,
                                compact: true,
                                onTap: sinStock
                                    ? null
                                    : () => widget.onAgregarAlCarrito(producto),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
