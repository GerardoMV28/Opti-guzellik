import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/producto_service.dart';
import '../../../models/productos/producto_model.dart';
import '../../../widgets/forms/index.dart';
import 'package:flutter/cupertino.dart';

class ProductoForm extends StatefulWidget {
  final Producto? producto;

  ProductoForm({this.producto});

  @override
  _ProductoFormState createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores básicos
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockController = TextEditingController();
  final _stockMinimoController = TextEditingController();

  // Variables de estado
  String _tipoSeleccionado = 'armazon';
  bool _isLoading = false;
  bool _isEditing = false;
  bool _cargandoOpciones = false;

  // Variables para selección inteligente de MICAS
  String? _presentacionSeleccionada;
  String? _materialMicaSeleccionado;
  String? _serieMicaSeleccionada;
  
  // Variables para selección inteligente de LENTES DE CONTACTO
  String? _marcaLCSeleccionada;
  String? _tipoLCSeleccionado;
  String? _disenoLCSeleccionado;

  // Listas dinámicas desde la BD
  List<String> _presentacionesMica = [];
  List<String> _materialesMica = [];
  List<String> _seriesMica = [];
  List<String> _marcasLC = [];
  List<String> _tiposLC = [];
  List<String> _disenosLC = [];

  // Listas estáticas solo para opciones que no vienen de la BD
  final List<String> _materialesArmazon = [
    'Metal', 'Acetato', 'Titanio', 'Flex', 'Madera', 'Combinado'
  ];
  
  final List<String> _tratamientosMica = [
    'W (Blanco)',
    'AR (Antireflejante)',
    'Blue Block',
    'Polarizado',
    'Fotocromático',
    'Espejeado',
  ];

  // Controladores
  final _materialArmazonController = TextEditingController();
  final _colorArmazonController = TextEditingController();
  String _generoArmazon = 'unisex';

  final _presentacionMicaController = TextEditingController();
  final _materialMicaController = TextEditingController();
  final _colorMicaController = TextEditingController();
  final _fabricanteMicaController = TextEditingController();
  final _serieMicaController = TextEditingController();
  final _rangoGraduacionController = TextEditingController();
  final List<String> _tratamientosSeleccionados = [];
  
  final _tipoLCController = TextEditingController();
  final _marcaLCController = TextEditingController();
  final _disenoLCController = TextEditingController();
  final _materialLCController = TextEditingController();
  final _reemplazoLCController = TextEditingController();
  final _parametrosLCController = TextEditingController();
  final _colorLCController = TextEditingController();

  final List<Map<String, dynamic>> _tiposProducto = [
    {'valor': 'armazon', 'label': 'Armazón', 'icon': CupertinoIcons.eyeglasses},
    {'valor': 'mica', 'label': 'Mica', 'icon': Icons.lens},
    {'valor': 'lente_contacto', 'label': 'Lente de Contacto', 'icon': Icons.contactless},
    {'valor': 'accesorio', 'label': 'Accesorio', 'icon': Icons.shopping_bag},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      _isEditing = true;
      _cargarDatosProducto();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar opciones desde la BD cuando se selecciona un tipo
    if (_tipoSeleccionado == 'mica' && _presentacionesMica.isEmpty) {
      _cargarOpcionesMica();
    }
    if (_tipoSeleccionado == 'lente_contacto' && _marcasLC.isEmpty) {
      _cargarOpcionesLenteContacto();
    }
  }

  Future<void> _cargarOpcionesMica() async {
    setState(() => _cargandoOpciones = true);
    try {
      final productos = await ProductoService.getProductosPorTipo('mica');
      
      _presentacionesMica = productos
          .map((p) => p.presentacionMica)
          .where((v) => v != null && v.isNotEmpty)
          .toSet()
          .toList()
          .cast<String>();
      
      _materialesMica = productos
          .map((p) => p.materialMica)
          .where((v) => v != null && v.isNotEmpty)
          .toSet()
          .toList()
          .cast<String>();
      
      _seriesMica = productos
          .map((p) => p.serieMica)
          .where((v) => v != null && v.isNotEmpty)
          .toSet()
          .toList()
          .cast<String>();
          
    } catch (e) {
      print('Error cargando opciones de mica: $e');
    } finally {
      setState(() => _cargandoOpciones = false);
    }
  }

  Future<void> _cargarOpcionesLenteContacto() async {
    setState(() => _cargandoOpciones = true);
    try {
      final productos = await ProductoService.getProductosPorTipo('lente_contacto');
      
      _marcasLC = productos
          .map((p) => p.marcaLC)
          .where((v) => v != null && v.isNotEmpty)
          .toSet()
          .toList()
          .cast<String>();
      
      _tiposLC = productos
          .map((p) => p.tipoLC)
          .where((v) => v != null && v.isNotEmpty)
          .toSet()
          .toList()
          .cast<String>();
      
      _disenosLC = productos
          .map((p) => p.disenoLC)
          .where((v) => v != null && v.isNotEmpty)
          .toSet()
          .toList()
          .cast<String>();
          
    } catch (e) {
      print('Error cargando opciones de lentes de contacto: $e');
    } finally {
      setState(() => _cargandoOpciones = false);
    }
  }

  Future<void> _cargarDatosPorSeleccionMica() async {
    if (_presentacionSeleccionada == null || 
        _materialMicaSeleccionado == null || 
        _serieMicaSeleccionada == null) return;
    
    setState(() => _cargandoOpciones = true);
    try {
      final productos = await ProductoService.getProductosPorTipo('mica');
      
      // Buscar un producto que coincida con la selección
      final productoEncontrado = productos.firstWhere(
        (p) => p.presentacionMica == _presentacionSeleccionada &&
               p.materialMica == _materialMicaSeleccionado &&
               p.serieMica == _serieMicaSeleccionada,
        orElse: () => productos.firstWhere(
          (p) => p.presentacionMica == _presentacionSeleccionada &&
                 p.materialMica == _materialMicaSeleccionado,
          orElse: () => productos.first,
        ),
      );
      
      // Autocompletar campos
      _rangoGraduacionController.text = productoEncontrado.rangoGraduacion ?? '';
      _fabricanteMicaController.text = productoEncontrado.fabricanteMica ?? '';
      _colorMicaController.text = productoEncontrado.colorMica ?? '';
      
      if (productoEncontrado.tratamientos != null) {
        _tratamientosSeleccionados.clear();
        _tratamientosSeleccionados.addAll(productoEncontrado.tratamientos!);
      }
      
    } catch (e) {
      print('Error cargando datos de mica: $e');
    } finally {
      setState(() => _cargandoOpciones = false);
    }
  }

  Future<void> _cargarDatosPorSeleccionLC() async {
    if (_marcaLCSeleccionada == null || 
        _tipoLCSeleccionado == null || 
        _disenoLCSeleccionado == null) return;
    
    setState(() => _cargandoOpciones = true);
    try {
      final productos = await ProductoService.getProductosPorTipo('lente_contacto');
      
      final productoEncontrado = productos.firstWhere(
        (p) => p.marcaLC == _marcaLCSeleccionada &&
               p.tipoLC == _tipoLCSeleccionado &&
               p.disenoLC == _disenoLCSeleccionado,
        orElse: () => productos.first,
      );
      
      _materialLCController.text = productoEncontrado.materialLC ?? '';
      _reemplazoLCController.text = productoEncontrado.reemplazoLC ?? '';
      _colorLCController.text = productoEncontrado.colorLC ?? '';
      _parametrosLCController.text = productoEncontrado.parametrosLC ?? '';
      
    } catch (e) {
      print('Error cargando datos de lente de contacto: $e');
    } finally {
      setState(() => _cargandoOpciones = false);
    }
  }

  void _cargarDatosProducto() {
    final p = widget.producto!;
    
    _tipoSeleccionado = p.tipo;
    _codigoController.text = p.codigo;
    _nombreController.text = p.nombre;
    _descripcionController.text = p.descripcion;
    _marcaController.text = p.marca;
    _modeloController.text = p.modelo;
    _precioCompraController.text = p.precioCompra.toString();
    _precioVentaController.text = p.precioVenta.toString();
    _stockController.text = p.stock.toString();
    _stockMinimoController.text = p.stockMinimo.toString();

    if (p.tipo == 'armazon') {
      _materialArmazonController.text = p.materialArmazon ?? '';
      _colorArmazonController.text = p.colorArmazon ?? '';
      _generoArmazon = p.generoArmazon ?? 'unisex';
    } else if (p.tipo == 'mica') {
      _presentacionSeleccionada = p.presentacionMica;
      _materialMicaSeleccionado = p.materialMica;
      _serieMicaSeleccionada = p.serieMica;
      
      _presentacionMicaController.text = p.presentacionMica ?? '';
      _materialMicaController.text = p.materialMica ?? '';
      _serieMicaController.text = p.serieMica ?? '';
      _rangoGraduacionController.text = p.rangoGraduacion ?? '';
      _fabricanteMicaController.text = p.fabricanteMica ?? '';
      _colorMicaController.text = p.colorMica ?? '';
      if (p.tratamientos != null) {
        _tratamientosSeleccionados.addAll(p.tratamientos!);
      }
    } else if (p.tipo == 'lente_contacto') {
      _marcaLCSeleccionada = p.marcaLC;
      _tipoLCSeleccionado = p.tipoLC;
      _disenoLCSeleccionado = p.disenoLC;
      
      _marcaLCController.text = p.marcaLC ?? '';
      _tipoLCController.text = p.tipoLC ?? '';
      _disenoLCController.text = p.disenoLC ?? '';
      _materialLCController.text = p.materialLC ?? '';
      _reemplazoLCController.text = p.reemplazoLC ?? '';
      _parametrosLCController.text = p.parametrosLC ?? '';
      _colorLCController.text = p.colorLC ?? '';
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _materialArmazonController.dispose();
    _colorArmazonController.dispose();
    _presentacionMicaController.dispose();
    _materialMicaController.dispose();
    _colorMicaController.dispose();
    _fabricanteMicaController.dispose();
    _serieMicaController.dispose();
    _rangoGraduacionController.dispose();
    _tipoLCController.dispose();
    _marcaLCController.dispose();
    _disenoLCController.dispose();
    _materialLCController.dispose();
    _reemplazoLCController.dispose();
    _parametrosLCController.dispose();
    _colorLCController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final productoData = {
        'tipo': _tipoSeleccionado,
        'codigo': _codigoController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'precios': {
          'costo': double.parse(_precioCompraController.text),
          'precio_venta': double.parse(_precioVentaController.text),
        },
        'stock': int.parse(_stockController.text),
        'stock_minimo': int.parse(_stockMinimoController.text),
        'imagenes': [],
      };

      if (_tipoSeleccionado == 'armazon') {
        productoData['armazon'] = {
          'material': _materialArmazonController.text,
          'color': _colorArmazonController.text,
          'genero': _generoArmazon,
        };
      } else if (_tipoSeleccionado == 'mica') {
        productoData['mica'] = {
          'presentacion': _presentacionMicaController.text,
          'material': _materialMicaController.text,
          'tratamientos': _tratamientosSeleccionados,
          'color': _colorMicaController.text,
          'serie': _serieMicaController.text,
          'rango_graduacion': _rangoGraduacionController.text,
          'fabricante': _fabricanteMicaController.text,
        };
      } else if (_tipoSeleccionado == 'lente_contacto') {
        productoData['lente_contacto'] = {
          'tipo': _tipoLCController.text,
          'marca_lc': _marcaLCController.text,
          'diseno': _disenoLCController.text,
          'material': _materialLCController.text,
          'reemplazo': _reemplazoLCController.text,
          'parametros': _parametrosLCController.text,
          'color': _colorLCController.text,
        };
      }

      if (_isEditing) {
        await ProductoService.updateProducto(widget.producto!.id, productoData);
      } else {
        await ProductoService.createProducto(productoData);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppColors.appBarGradient)),
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: _cargandoOpciones
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    FormCard(
                      child: Column(
                        children: [
                          CustomDropdown<String>(
                            value: _tipoSeleccionado,
                            label: 'Tipo de producto',
                            icon: Icons.category_outlined,
                            items: _tiposProducto.map((tipo) {
                              return DropdownMenuItem<String>(
                                value: tipo['valor'] as String,
                                child: Row(
                                  children: [
                                    Icon(tipo['icon'] as IconData, size: 20),
                                    SizedBox(width: 8),
                                    Text(tipo['label'] as String),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _tipoSeleccionado = value!;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _codigoController,
                                  label: 'Código',
                                  prefixIcon: Icons.qr_code,
                                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _nombreController,
                                  label: 'Nombre',
                                  prefixIcon: Icons.label_outline,
                                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _marcaController,
                                  label: 'Marca',
                                  prefixIcon: Icons.branding_watermark,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _modeloController,
                                  label: 'Modelo',
                                  prefixIcon: Icons.model_training,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _descripcionController,
                            label: 'Descripción',
                            prefixIcon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _precioCompraController,
                                  label: 'Precio compra',
                                  prefixIcon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _precioVentaController,
                                  label: 'Precio venta',
                                  prefixIcon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _stockController,
                                  label: 'Stock actual',
                                  prefixIcon: Icons.inventory,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _stockMinimoController,
                                  label: 'Stock mínimo',
                                  prefixIcon: Icons.warning_amber_rounded,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 32),
                          if (_tipoSeleccionado == 'armazon') _buildArmazonFields(),
                          if (_tipoSeleccionado == 'mica') _buildMicaFields(),
                          if (_tipoSeleccionado == 'lente_contacto') _buildLenteContactoFields(),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancelar',
                            onPressed: () => Navigator.pop(context),
                            isOutlined: true,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: _isEditing ? 'Actualizar' : 'Guardar',
                            onPressed: _guardarProducto,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildArmazonFields() {
    return Column(
      children: [
        Text('Características del Armazón', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomDropdown<String>(
                value: _materialArmazonController.text.isNotEmpty ? _materialArmazonController.text : null,
                label: 'Material',
                icon: Icons.science_outlined,
                items: _materialesArmazon.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _materialArmazonController.text = v ?? ''),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: CustomTextField(controller: _colorArmazonController, label: 'Color', prefixIcon: Icons.palette_outlined),
            ),
          ],
        ),
        SizedBox(height: 16),
        CustomDropdown<String>(
          value: _generoArmazon,
          label: 'Género',
          icon: Icons.people_outline,
          items: ['hombre', 'mujer', 'unisex'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _generoArmazon = v!),
        ),
      ],
    );
  }

  Widget _buildMicaFields() {
    return Column(
      children: [
        Text('Características de la Mica', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        if (_presentacionesMica.isNotEmpty)
          CustomDropdown<String>(
            value: _presentacionSeleccionada,
            label: 'Presentación',
            icon: Icons.category_outlined,
            items: _presentacionesMica.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) {
              setState(() {
                _presentacionSeleccionada = v;
                _presentacionMicaController.text = v ?? '';
              });
            },
          ),
        SizedBox(height: 16),
        if (_materialesMica.isNotEmpty)
          CustomDropdown<String>(
            value: _materialMicaSeleccionado,
            label: 'Material',
            icon: Icons.science_outlined,
            items: _materialesMica.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) {
              setState(() {
                _materialMicaSeleccionado = v;
                _materialMicaController.text = v ?? '';
                _cargarDatosPorSeleccionMica();
              });
            },
          ),
        SizedBox(height: 16),
        if (_seriesMica.isNotEmpty)
          CustomDropdown<String>(
            value: _serieMicaSeleccionada,
            label: 'Serie / Rango',
            icon: Icons.format_list_numbered_outlined,
            items: _seriesMica.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) {
              setState(() {
                _serieMicaSeleccionada = v;
                _serieMicaController.text = v ?? '';
                _cargarDatosPorSeleccionMica();
              });
            },
          ),
        SizedBox(height: 16),
        CustomTextField(controller: _rangoGraduacionController, label: 'Rango de Graduación', prefixIcon: Icons.visibility_outlined),
        SizedBox(height: 16),
        CustomTextField(controller: _fabricanteMicaController, label: 'Fabricante', prefixIcon: Icons.business_outlined),
        SizedBox(height: 16),
        Text('Tratamientos', style: TextStyle(fontWeight: FontWeight.w500)),
        Wrap(
          spacing: 8,
          children: _tratamientosMica.map((t) => FilterChip(
            label: Text(t),
            selected: _tratamientosSeleccionados.contains(t),
            onSelected: (s) => setState(() => s ? _tratamientosSeleccionados.add(t) : _tratamientosSeleccionados.remove(t)),
          )).toList(),
        ),
        SizedBox(height: 16),
        CustomTextField(controller: _colorMicaController, label: 'Color', prefixIcon: Icons.palette_outlined),
      ],
    );
  }

  Widget _buildLenteContactoFields() {
    return Column(
      children: [
        Text('Características del Lente de Contacto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        if (_marcasLC.isNotEmpty)
          CustomDropdown<String>(
            value: _marcaLCSeleccionada,
            label: 'Marca',
            icon: Icons.branding_watermark,
            items: _marcasLC.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) {
              setState(() {
                _marcaLCSeleccionada = v;
                _marcaLCController.text = v ?? '';
              });
            },
          ),
        SizedBox(height: 16),
        if (_tiposLC.isNotEmpty)
          CustomDropdown<String>(
            value: _tipoLCSeleccionado,
            label: 'Tipo',
            icon: Icons.category_outlined,
            items: _tiposLC.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) {
              setState(() {
                _tipoLCSeleccionado = v;
                _tipoLCController.text = v ?? '';
              });
            },
          ),
        SizedBox(height: 16),
        if (_disenosLC.isNotEmpty)
          CustomDropdown<String>(
            value: _disenoLCSeleccionado,
            label: 'Diseño',
            icon: Icons.design_services_outlined,
            items: _disenosLC.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) {
              setState(() {
                _disenoLCSeleccionado = v;
                _disenoLCController.text = v ?? '';
                _cargarDatosPorSeleccionLC();
              });
            },
          ),
        SizedBox(height: 16),
        CustomTextField(controller: _materialLCController, label: 'Material', prefixIcon: Icons.science_outlined),
        SizedBox(height: 16),
        CustomTextField(controller: _reemplazoLCController, label: 'Reemplazo', prefixIcon: Icons.update),
        SizedBox(height: 16),
        CustomTextField(controller: _parametrosLCController, label: 'Parámetros', prefixIcon: Icons.tune_outlined, maxLines: 2),
        SizedBox(height: 16),
        CustomTextField(controller: _colorLCController, label: 'Color', prefixIcon: Icons.palette_outlined),
      ],
    );
  }
}