// lib/screens/empleado/productos/productos_empleado.dart
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/producto_service.dart';
import '../../../models/productos/producto_model.dart';
import '../../admin/productos/producto_form.dart';

class ProductosEmpleado extends StatefulWidget {
  @override
  _ProductosEmpleadoState createState() => _ProductosEmpleadoState();
}

class _ProductosEmpleadoState extends State<ProductosEmpleado> {
  List<Producto> _productos = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productos = await ProductoService.getProductos();
      setState(() {
        _productos = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<Producto> get _productosFiltrados {
    if (_searchQuery.isEmpty) return _productos;
    return _productos.where((p) {
      return p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.codigo.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _agregarProducto() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoForm(),
      ),
    );
    if (result == true) {
      _cargarProductos();
    }
  }

  Future<void> _editarProducto(Producto producto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoForm(producto: producto),
      ),
    );
    if (result == true) {
      _cargarProductos();
    }
  }

  Future<void> _eliminarProducto(Producto producto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ProductoService.deleteProducto(producto.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${producto.nombre} eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarProductos();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.azulReal,
        title: Text(
          'Catálogo de Productos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.azulReal,
          ),
        ),
        actions: [
          // Botón de recargar
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.azulReal),
            onPressed: _cargarProductos,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search, color: AppColors.azulCobalto),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarProducto,
        backgroundColor: AppColors.turquesa,
        child: Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.azulReal),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: $_errorMessage'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarProductos,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _productosFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay productos registrados'),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _agregarProducto,
                            icon: Icon(Icons.add),
                            label: Text('Agregar Producto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.turquesa,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = _productosFiltrados[index];
                        return _buildProductoCard(producto);
                      },
                    ),
    );
  }

  Widget _buildProductoCard(Producto producto) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono según tipo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getColorForTipo(producto.tipo).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForTipo(producto.tipo),
                color: _getColorForTipo(producto.tipo),
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulReal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Código: ${producto.codigo}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Marca: ${producto.marca}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${producto.precioVenta.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.turquesa,
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: producto.stock <= producto.stockMinimo
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Stock: ${producto.stock}',
                          style: TextStyle(
                            fontSize: 11,
                            color: producto.stock <= producto.stockMinimo
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Botones de acción
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.azulCobalto, size: 20),
                  onPressed: () => _editarProducto(producto),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => _eliminarProducto(producto),
                ),
              ],
            ),
          ],
        ),
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