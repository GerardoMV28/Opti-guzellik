import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/colors.dart';
import '../../../services/reporte_service.dart';
import '../../../models/reportes/venta_reporte_model.dart';
import '../../../models/reportes/resumen_ventas_model.dart';
import '../../../models/reportes/producto_top_model.dart';
import '../../../widgets/graficas/grafica_barras.dart';
import '../../../widgets/graficas/grafica_pastel.dart';
import '../../../services/export_service.dart';
import '../../../services/producto_service.dart';
import '../../../models/productos/producto_model.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // Fechas para filtros
  DateTime _fechaInicio = DateTime.now().subtract(Duration(days: 30));
  DateTime _fechaFin = DateTime.now();
  
  // Datos de reportes
  ResumenVentas? _resumenVentas;
  List<VentaReporte> _ventasDelDia = [];
  List<ProductoTop> _productosTop = [];
  List<dynamic> _productosBajoStock = [];
  Map<String, dynamic> _ventasPorEmpleado = {};
  List<Producto> _productos = [];

  final DateFormat _formatter = DateFormat('dd/MM/yyyy');
  final NumberFormat _moneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _cargarTodosLosReportes();
  }

  Future<void> _exportarPDF() async {
    if (_resumenVentas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Espera a que carguen los datos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      await ExportService.exportarReportePDF(
        resumen: _resumenVentas!,
        ventas: _ventasDelDia,
        productosTop: _productosTop,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        titulo: 'Reporte de Ventas - Óptica Güzellik',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportarExcel() async {
    if (_resumenVentas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Espera a que carguen los datos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    try {
      await ExportService.exportarReporteExcel(
        resumen: _resumenVentas!,
        ventas: _ventasDelDia,
        productosTop: _productosTop,
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cargarTodosLosReportes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Cargar todos los reportes en paralelo
      await Future.wait([
        _cargarResumenVentas(),
        _cargarVentasDelDia(),
        _cargarProductosTop(),
        _cargarProductosBajoStock(),
        _cargarVentasPorEmpleado(),
        _cargarProductos(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cargarResumenVentas() async {
    final resumen = await ReporteService.getResumenVentas(
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
    );
    setState(() {
      _resumenVentas = resumen;
    });
  }

  Future<void> _cargarVentasDelDia() async {
    final ventas = await ReporteService.getVentasDelDia();
    setState(() {
      _ventasDelDia = ventas;
    });
  }

  Future<void> _cargarProductosTop() async {
    final productos = await ReporteService.getProductosMasVendidos(
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
      limite: 5,
    );
    setState(() {
      _productosTop = productos;
    });
  }

  Future<void> _cargarProductosBajoStock() async {
    final productos = await ReporteService.getProductosBajoStock();
    setState(() {
      _productosBajoStock = productos;
    });
  }

  Future<void> _cargarVentasPorEmpleado() async {
    final ventas = await ReporteService.getVentasPorEmpleado(
      fechaInicio: _fechaInicio,
      fechaFin: _fechaFin,
    );
    setState(() {
      _ventasPorEmpleado = ventas;
    });
  }

  Future<void> _cargarProductos() async {
    final productos = await ProductoService.getProductos();
    setState(() {
      _productos = productos;
    });
  }

  List<Producto> get _productosActivos => _productos.where((p) => p.activo).toList();

  double get _valorInventarioCosto =>
      _productosActivos.fold(0.0, (s, p) => s + p.stock * p.precioCompra);

  double get _valorInventarioVenta =>
      _productosActivos.fold(0.0, (s, p) => s + p.stock * p.precioVenta);

  Future<void> _exportarInventarioPDF() async {
    try {
      await ExportService.exportarInventarioPDF(productos: _productos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar inventario: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exportarInventarioExcel() async {
    try {
      await ExportService.exportarInventarioExcel(productos: _productos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar inventario: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _seleccionarRangoFechas() async {
    final DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _fechaInicio,
        end: _fechaFin,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.azulReal,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (rango != null) {
      setState(() {
        _fechaInicio = rango.start;
        _fechaFin = rango.end;
      });
      _cargarTodosLosReportes();
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
                      'Reportes y Estadísticas',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    Row(
                      children: [
                        // Botón Exportar PDF
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _exportarPDF,
                          icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                          label: Text('PDF'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                          ),
                        ),
                        SizedBox(width: 12),
                        // Botón Exportar Excel
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _exportarExcel,
                          icon: Icon(Icons.table_chart, color: Colors.green),
                          label: Text('Excel'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.green),
                            foregroundColor: Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        // Botón selector de fechas
                        ElevatedButton.icon(
                          onPressed: _seleccionarRangoFechas,
                          icon: Icon(Icons.date_range),
                          label: Text(
                            '${_formatter.format(_fechaInicio)} - ${_formatter.format(_fechaFin)}',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.azulCobalto,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contenido
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
                              'Error al cargar reportes',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(_errorMessage!),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cargarTodosLosReportes,
                              child: Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Tarjetas de resumen
                            if (_resumenVentas != null) ...[
                              _buildTarjetasResumen(),
                              SizedBox(height: 24),
                            ],

                            // Gráficas
                            _buildGraficas(),
                            SizedBox(height: 24),

                            // Tablas de datos
                            _buildTablasDatos(),
                            SizedBox(height: 24),

                            // Inventario (no depende del rango de fechas)
                            _buildSeccionInventario(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetasResumen() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildTarjetaResumen(
          'Ventas totales',
          _moneda.format(_resumenVentas!.totalVentas),
          Icons.attach_money,
          Colors.green,
          '${_resumenVentas!.cantidadVentas} ventas',
        ),
        _buildTarjetaResumen(
          'Efectivo',
          _moneda.format(_resumenVentas!.efectivo),
          Icons.money,
          Colors.blue,
          '${((_resumenVentas!.efectivo / _resumenVentas!.totalVentas) * 100).toStringAsFixed(1)}%',
        ),
        _buildTarjetaResumen(
          'Tarjeta',
          _moneda.format(_resumenVentas!.tarjeta),
          Icons.credit_card,
          Colors.purple,
          '${((_resumenVentas!.tarjeta / _resumenVentas!.totalVentas) * 100).toStringAsFixed(1)}%',
        ),
        _buildTarjetaResumen(
          'Promedio',
          _moneda.format(_resumenVentas!.promedioVenta),
          Icons.trending_up,
          Colors.orange,
          'por venta',
        ),
      ],
    );
  }

  Widget _buildTarjetaResumen(String titulo, String valor, IconData icono, Color color, String subtitulo) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: color),
              ),
              Text(
                subtitulo,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.azulReal,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficas() {
    // Datos para gráfica de ventas por empleado
    Map<String, double> ventasPorEmpleadoMap = {};
    _ventasPorEmpleado.forEach((empleado, total) {
      ventasPorEmpleadoMap[empleado] = (total as num).toDouble();
    });

    // Datos para gráfica de productos top
    Map<String, double> productosTopMap = {};
    for (var producto in _productosTop) {
      productosTopMap[producto.nombre] = producto.totalVendido;
    }

    // Datos para gráfica de métodos de pago
    Map<String, double> metodosPagoMap = {};
    if (_resumenVentas != null) {
      metodosPagoMap['Efectivo'] = _resumenVentas!.efectivo;
      metodosPagoMap['Tarjeta'] = _resumenVentas!.tarjeta;
      if (_resumenVentas!.transferencia > 0) {
        metodosPagoMap['Transferencia'] = _resumenVentas!.transferencia;
      }
    }

    return Column(
      children: [
        // Siempre mostrar la gráfica, el widget maneja internamente si hay datos
        GraficaBarras(
          datos: ventasPorEmpleadoMap,
          titulo: 'Ventas por Empleado',
          color: AppColors.azulReal,
        ),
        SizedBox(height: 24),
        GraficaBarras(
          datos: productosTopMap,
          titulo: 'Productos Más Vendidos',
          color: AppColors.turquesa,
        ),
        SizedBox(height: 24),
        GraficaPastel(
          datos: metodosPagoMap,
          titulo: 'Métodos de Pago',
        ),
      ],
    );
  }

  Widget _buildTablasDatos() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Productos con stock bajo
        Expanded(
          flex: 2,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Productos con Stock Bajo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _productosBajoStock.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No hay productos con stock bajo',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _productosBajoStock.length,
                          itemBuilder: (context, index) {
                            final producto = _productosBajoStock[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto['nombre'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          producto['codigo'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Stock: ${producto['stock']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 24),
        // Ventas del día
        Expanded(
          flex: 3,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.today, color: AppColors.turquesa),
                      SizedBox(width: 8),
                      Text(
                        'Ventas del Día',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ventasDelDia.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'No hay ventas hoy',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _ventasDelDia.length,
                          itemBuilder: (context, index) {
                            final venta = _ventasDelDia[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.azulCobalto.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        DateFormat('HH:mm').format(venta.fecha),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.azulCobalto,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          venta.vendedor,
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          '${venta.cantidadProductos} productos',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _moneda.format(venta.total),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.azulReal,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: venta.formaPago == 'efectivo'
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.purple.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          venta.formaPago == 'efectivo' ? 'Efectivo' : 
                                          venta.formaPago == 'tarjeta' ? 'Tarjeta' : 'Transferencia',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: venta.formaPago == 'efectivo'
                                                ? Colors.green
                                                : Colors.purple,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionInventario() {
    final activos = _productosActivos;
    final unidades = activos.fold<int>(0, (s, p) => s + p.stock);
    final valorCosto = _valorInventarioCosto;
    final valorVenta = _valorInventarioVenta;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: AppColors.azulReal),
                    SizedBox(width: 8),
                    Text(
                      'Inventario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _productos.isEmpty ? null : _exportarInventarioPDF,
                      icon: Icon(Icons.picture_as_pdf, color: Colors.red, size: 18),
                      label: Text('PDF'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _productos.isEmpty ? null : _exportarInventarioExcel,
                      icon: Icon(Icons.table_chart, color: Colors.green, size: 18),
                      label: Text('Excel'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Corte del inventario actual (no depende del rango de fechas de arriba).',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildTarjetaResumen(
                  'Productos activos',
                  activos.length.toString(),
                  Icons.inventory,
                  Colors.blue,
                  'en catálogo',
                ),
                _buildTarjetaResumen(
                  'Unidades en stock',
                  unidades.toString(),
                  Icons.numbers,
                  Colors.indigo,
                  'piezas',
                ),
                _buildTarjetaResumen(
                  'Valor a costo',
                  _moneda.format(valorCosto),
                  Icons.attach_money,
                  Colors.orange,
                  'inversión',
                ),
                _buildTarjetaResumen(
                  'Valor a precio venta',
                  _moneda.format(valorVenta),
                  Icons.sell,
                  Colors.green,
                  'potencial',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}