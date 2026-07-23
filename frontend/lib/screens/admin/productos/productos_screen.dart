import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/producto_service.dart';
import '../../../models/productos/producto_model.dart';
import '../../../widgets/forms/form_card.dart';
import 'producto_form.dart';

class ProductosScreen extends StatefulWidget {
  @override
  _ProductosScreenState createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> _productos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _filtroTipo = 'todos';
  bool _mostrarInactivos = false;

  final List<String> _tipos = [
    'todos',
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

  Future<void> _cargarProductos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productos = await ProductoService.getProductos();
      setState(() {
        _productos = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Producto> get _productosFiltrados {
    var resultados = _productos;

    // Filtrar inactivos
    if (!_mostrarInactivos) {
      resultados = resultados.where((p) => p.activo).toList();
    }

    // Filtrar por tipo
    if (_filtroTipo != 'todos') {
      resultados = resultados.where((p) => p.tipo == _filtroTipo).toList();
    }
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      resultados = resultados.where((p) {
        return p.nombre.toLowerCase().contains(query) ||
               p.codigo.toLowerCase().contains(query) ||
               p.marca.toLowerCase().contains(query);
      }).toList();
    }
    
    return resultados;
  }

  void _nuevoProducto() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductoForm()),
    );
    if (result == true) {
      _cargarProductos();
    }
  }

  void _editarProducto(Producto producto) async {
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
        content: Text('¿Estás seguro de eliminar ${producto.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ProductoService.deleteProducto(producto.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto eliminado correctamente'),
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Cabecera
          Container(
            padding: EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catálogo de Productos',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _nuevoProducto,
                      icon: Icon(Icons.add),
                      label: Text('Nuevo Producto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.turquesa,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Filtros y búsqueda
                Row(
                  children: [
                    // Filtro por tipo
                    Container(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _filtroTipo,
                        decoration: InputDecoration(
                          labelText: 'Filtrar por tipo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: _tipos.map((tipo) {
                          String label = tipo == 'todos' 
                              ? 'Todos' 
                              : _getTipoEspanol(tipo);
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _filtroTipo = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),

                    // Barra de búsqueda
                    Expanded(
                      child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre, código o marca...',
                            prefixIcon: Icon(Icons.search, color: AppColors.azulCobalto),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                      ),
                    ),
                    SizedBox(width: 16),
                    Switch(
                      value: _mostrarInactivos,
                      activeColor: AppColors.azulCobalto,
                      onChanged: (value) {
                        setState(() {
                          _mostrarInactivos = value;
                        });
                      },
                    ),
                    Text(
                      'Mostrar inactivos',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de productos
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'Error al cargar productos',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(_errorMessage!),
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
                                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No hay productos',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Agrega un nuevo producto para comenzar',
                                  style: TextStyle(color: Colors.grey),
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
          ),
        ],
      ),
    );
  }

  Widget _buildProductoCard(Producto producto) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: FormCard(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            border: producto.activo
                ? null
                : Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: producto.colorTipo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: producto.imagenes.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      producto.imagenes.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: producto.colorTipo,
                      size: 30,
                    ),
                  ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  producto.nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: producto.activo ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              if (!producto.activo) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Inactivo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                '${producto.codigo} • ${producto.marca}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: producto.colorTipo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      producto.tipoEnEspanol,
                      style: TextStyle(
                        fontSize: 11,
                        color: producto.colorTipo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Stock: ${producto.stock}',
                    style: TextStyle(
                      fontSize: 13,
                      color: producto.stock <= producto.stockMinimo
                          ? Colors.orange
                          : Colors.green,
                      fontWeight: producto.stock <= producto.stockMinimo
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '\$${producto.precioVenta.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulReal,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  leading: Icon(Icons.edit, color: AppColors.azulCobalto),
                  title: Text('Editar'),
                ),
              ),
              PopupMenuItem(
                value: 'ajustar_stock',
                child: ListTile(
                  leading: Icon(Icons.inventory, color: Colors.orange),
                  title: Text('Ajustar stock'),
                ),
              ),
              PopupMenuItem(
                value: 'eliminar',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Eliminar'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'editar') {
                _editarProducto(producto);
              } else if (value == 'ajustar_stock') {
                _mostrarDialogoStock(producto);
              } else if (value == 'eliminar') {
                _eliminarProducto(producto);
              }
            },
          ),
        ),
        ),
      ),
    );
  }

  void _mostrarDialogoStock(Producto producto) {
    final stockController = TextEditingController(text: producto.stock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajustar stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Producto: ${producto.nombre}'),
            SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nuevo stock',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoStock = int.tryParse(stockController.text);
              if (nuevoStock != null) {
                try {
                  await ProductoService.updateStock(producto.id, nuevoStock);
                  _cargarProductos();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stock actualizado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Actualizar'),
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
        return 'Lentes de Contacto';
      case 'accesorio':
        return 'Accesorios';
      default:
        return tipo;
    }
  }
}