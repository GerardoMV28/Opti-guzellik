import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/producto_service.dart';
import '../../../models/productos/producto_model.dart';
import '../../../models/ventas/venta_model.dart';
import 'pago_screen.dart';
import 'ventas_lista_tipo_screen.dart';
import '../../../widgets/ventas/carrito_widget.dart';

class VentasScreen extends StatefulWidget {
  @override
  _VentasScreenState createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<Producto> _productos = [];
  List<ItemVenta> _carrito = [];
  bool _isLoading = true;
  String? _errorMessage;

  final ValueNotifier<int> _carritoVersion = ValueNotifier(0);

  static const List<String> _tiposCatalogo = [
    'armazon',
    'mica',
    'lente_contacto',
    'accesorio',
  ];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _carritoVersion.dispose();
    super.dispose();
  }

  void _bumpCarrito() {
    _carritoVersion.value++;
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productos = await ProductoService.getProductos();
      setState(() {
        _productos = productos.where((p) => p.activo && p.stock > 0).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _ajustarDescuentoPorCantidad(ItemVenta item) {
    final maxDesc = item.precioUnitario * item.cantidad;
    if (item.descuento > maxDesc) {
      item.descuento = maxDesc;
    }
  }

  void _agregarAlCarrito(Producto producto) {
    setState(() {
      final index = _carrito.indexWhere(
        (item) => item.productoId == producto.id,
      );

      if (index != -1) {
        _carrito[index].cantidad++;
        _ajustarDescuentoPorCantidad(_carrito[index]);
      } else {
        _carrito.add(
          ItemVenta(
            productoId: producto.id,
            nombre: producto.nombre,
            codigo: producto.codigo,
            tipo: producto.tipo,
            precioUnitario: producto.precioVenta,
            cantidad: 1,
            descuento: 0,
          ),
        );
      }
    });
    _bumpCarrito();
  }

  void _eliminarDelCarrito(ItemVenta item) {
    setState(() {
      _carrito.remove(item);
    });
    _bumpCarrito();
  }

  void _actualizarCantidad(ItemVenta item, int nuevaCantidad) {
    setState(() {
      if (nuevaCantidad <= 0) {
        _carrito.remove(item);
      } else {
        item.cantidad = nuevaCantidad;
        _ajustarDescuentoPorCantidad(item);
      }
    });
    _bumpCarrito();
  }

  /// Suma de precio × cantidad (antes de descuentos por línea).
  double get _subtotalBruto {
    return _carrito.fold(
      0.0,
      (sum, item) => sum + item.precioUnitario * item.cantidad,
    );
  }

  double get _descuentoTotal {
    return _carrito.fold(0.0, (sum, item) => sum + item.descuento);
  }

  double get _total {
    return _subtotalBruto - _descuentoTotal;
  }

  void _abrirTipo(String tipo) {
    final lista = _productos.where((p) => p.tipo == tipo).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VentasListaTipoScreen(
          tipo: tipo,
          productos: lista,
          carritoVersion: _carritoVersion,
          carrito: _carrito,
          onAgregarAlCarrito: (p) {
            _agregarAlCarrito(p);
          },
        ),
      ),
    );
  }

  void _editarDescuento(ItemVenta item) {
    final maxDesc = item.precioUnitario * item.cantidad;
    final controller = TextEditingController(
      text: item.descuento > 0 ? item.descuento.toStringAsFixed(2) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Descuento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.nombre,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'Máximo: \$${maxDesc.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto a descontar',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final raw = controller.text.replaceAll(',', '.').trim();
              final v = double.tryParse(raw) ?? 0;
              if (v < 0 || v > maxDesc + 0.001) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'El descuento debe estar entre 0 y \$${maxDesc.toStringAsFixed(2)}',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              setState(() {
                item.descuento = v;
              });
              Navigator.pop(ctx);
              _bumpCarrito();
            },
            child: Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizarVenta() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Agrega productos al carrito'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PagoScreen(
          carrito: _carrito,
          subtotal: _subtotalBruto,
          descuentoTotal: _descuentoTotal,
          total: _total,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _carrito.clear();
      });
      _bumpCarrito();
      _cargarProductos();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Punto de Venta',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.azulReal,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Actualizar catálogo',
                            onPressed: _cargarProductos,
                            icon: Icon(Icons.refresh, color: AppColors.azulReal),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Elige un tipo de producto para ver el catálogo',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(child: Text('Error: $_errorMessage'))
                          : _productos.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inventory,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text('No hay productos disponibles'),
                                    ],
                                  ),
                                )
                              : _buildTipoHub(),
                ),
              ],
            ),
          ),
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart, color: AppColors.azulReal),
                      SizedBox(width: 12),
                      Text(
                        'Carrito de Compras',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                      Spacer(),
                      if (_carrito.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _carrito.clear();
                            });
                            _bumpCarrito();
                          },
                          child: Text(
                            'Vaciar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _carrito.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Carrito vacío',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(12),
                          itemCount: _carrito.length,
                          itemBuilder: (context, index) {
                            final item = _carrito[index];
                            Producto? productoOriginal;
                            try {
                              productoOriginal = _productos.firstWhere(
                                (p) => p.id == item.productoId,
                              );
                            } catch (e) {
                              productoOriginal = null;
                            }
                            final stockMaximo = productoOriginal?.stock ?? 0;

                            return CarritoWidget(
                              item: item,
                              stockMaximo: stockMaximo,
                              onCantidadChanged: (nuevaCantidad) {
                                _actualizarCantidad(item, nuevaCantidad);
                              },
                              onEliminar: () {
                                _eliminarDelCarrito(item);
                              },
                              onEditarDescuento: () => _editarDescuento(item),
                            );
                          },
                        ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Column(
                    children: [
                      _buildResumenRow(
                        'Subtotal',
                        '\$${_subtotalBruto.toStringAsFixed(2)}',
                      ),
                      _buildResumenRow(
                        'Descuentos',
                        '-\$${_descuentoTotal.toStringAsFixed(2)}',
                      ),
                      Divider(),
                      _buildResumenRow(
                        'Total',
                        '\$${_total.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _finalizarVenta,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.turquesa,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'FINALIZAR VENTA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoHub() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.35,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _tiposCatalogo.length,
        itemBuilder: (context, i) {
          final tipo = _tiposCatalogo[i];
          final n = _productos.where((p) => p.tipo == tipo).length;
          final color = _colorTipo(tipo);
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _abrirTipo(tipo),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_iconTipo(tipo), size: 40, color: color),
                    ),
                    SizedBox(height: 14),
                    Text(
                      _getTipoEspanol(tipo),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '$n producto${n == 1 ? '' : 's'} con stock',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ver catálogo',
                          style: TextStyle(
                            color: AppColors.turquesa,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.turquesa),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _colorTipo(String tipo) {
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

  IconData _iconTipo(String tipo) {
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

  Widget _buildResumenRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.azulReal : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getTipoEspanol(String tipo) {
    switch (tipo) {
      case 'armazon':
        return 'Armazones';
      case 'mica':
        return 'Micas';
      case 'lente_contacto':
        return 'Lentes de contacto';
      case 'accesorio':
        return 'Accesorios';
      default:
        return tipo;
    }
  }
}
