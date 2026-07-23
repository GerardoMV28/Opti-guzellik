  import 'package:flutter/services.dart';
  import 'package:intl/intl.dart';
  import 'package:pdf/pdf.dart';
  import 'package:pdf/widgets.dart' as pw;
  import 'package:printing/printing.dart';
  import 'package:excel/excel.dart';
  import 'platform/export_saver_stub.dart'
      if (dart.library.io) 'platform/export_saver_io.dart'
      if (dart.library.html) 'platform/export_saver_web.dart';
  import '../models/reportes/resumen_ventas_model.dart';
  import '../models/reportes/venta_reporte_model.dart';
  import '../models/reportes/producto_top_model.dart';
  import '../models/productos/producto_model.dart';

  class ExportService {
    static final NumberFormat _moneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
    static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    // Variable para cachear la imagen del logo
    static Uint8List? _cachedLogoBytes;

    // ==================== FUNCIÓN PARA CARGAR EL LOGO ====================
    
    /// Carga el logo desde los assets
    static Future<Uint8List?> _cargarLogo() async {
      if (_cachedLogoBytes != null) return _cachedLogoBytes;
      
      try {
        final ByteData data = await rootBundle.load('assets/images/Guzellik.jpeg');
        _cachedLogoBytes = data.buffer.asUint8List();
        
        return _cachedLogoBytes;
      } catch (e) {
        return null;
      }
    }

    // ==================== EXPORTAR A PDF ====================

    static Future<void> exportarReportePDF({
      required ResumenVentas resumen,
      required List<VentaReporte> ventas,
      required List<ProductoTop> productosTop,
      required DateTime fechaInicio,
      required DateTime fechaFin,
      String titulo = 'Reporte de Ventas',
    }) async {
      try {
        
        final pdf = pw.Document();
        final logoBytes = await _cargarLogo();

        
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(20),
            build: (pw.Context context) => [
              // Encabezado con logo
              _buildHeader(titulo, fechaInicio, fechaFin, logoBytes),
              pw.SizedBox(height: 20),
              
              // Resumen de ventas
              _buildResumenSection(resumen),
              pw.SizedBox(height: 20),
              
              // Productos más vendidos
              _buildProductosTopSection(productosTop),
              pw.SizedBox(height: 20),
              
              // Ventas detalladas
              _buildVentasDetalladasSection(ventas),
              
              // Pie de página (sin contexto)
              pw.SizedBox(height: 30),
              _buildFooter(),
            ],
          ),
        );

        final bytes = await pdf.save();

        
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'reporte_ventas_${_dateFormat.format(DateTime.now())}.pdf',
        );
     
      } catch (e) {
       
        rethrow;
      }
    }

    static pw.Widget _buildHeader(String titulo, DateTime inicio, DateTime fin, Uint8List? logoBytes) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Fila con logo y título
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo - Manejo seguro para evitar null
              if (logoBytes != null)
                pw.Container(
                  width: 60,
                  height: 60,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                // Placeholder cuando no hay logo
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Icon(pw.IconData(0xe3c9), color: PdfColors.grey500),
                ),
              pw.SizedBox(width: 12),
              // Información de la empresa
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Óptica Güzellik',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    'Sistema de Punto de Venta',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'www.opticaguzellik.com',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Período: ${_dateFormat.format(inicio)} - ${_dateFormat.format(fin)}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Text(
            'Fecha de generación: ${_dateTimeFormat.format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
        ],
      );
    }

    static pw.Widget _buildFooter() {
      return pw.Column(
        children: [
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Óptica Güzellik - Tu salud visual es nuestra prioridad',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
              pw.Text(
                'Documento generado el ${_dateTimeFormat.format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      );
    }

    static pw.Widget _buildResumenSection(ResumenVentas resumen) {
      // Asegurar que los valores no sean null
      final totalVentas = resumen.totalVentas;
      final cantidadVentas = resumen.cantidadVentas;
      final promedioVenta = resumen.promedioVenta;
      final efectivo = resumen.efectivo;
      final tarjeta = resumen.tarjeta;
      final transferencia = resumen.transferencia;

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumen de Ventas',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                _buildInfoRow('Total Ventas', _moneda.format(totalVentas)),
                _buildInfoRow('Cantidad de Ventas', cantidadVentas.toString()),
                _buildInfoRow('Ticket Promedio', _moneda.format(promedioVenta)),
                pw.SizedBox(height: 8),
                pw.Divider(),
                _buildInfoRow('Efectivo', _moneda.format(efectivo)),
                _buildInfoRow('Tarjeta', _moneda.format(tarjeta)),
                _buildInfoRow('Transferencia', _moneda.format(transferencia)),
              ],
            ),
          ),
        ],
      );
    }

    static pw.Widget _buildProductosTopSection(List<ProductoTop> productos) {
      if (productos.isEmpty) {
        return pw.Container();
      }

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Productos Más Vendidos',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableCell('Producto', isHeader: true),
                  _buildTableCell('Cantidad', isHeader: true),
                  _buildTableCell('Total', isHeader: true),
                ],
              ),
              ...productos.map((producto) => pw.TableRow(
                children: [
                  _buildTableCell(producto.nombre),
                  _buildTableCell(producto.cantidadVendida.toString()),
                  _buildTableCell(_moneda.format(producto.totalVendido)),
                ],
              )),
            ],
          ),
        ],
      );
    }

    static pw.Widget _buildVentasDetalladasSection(List<VentaReporte> ventas) {
      if (ventas.isEmpty) {
        return pw.Container();
      }

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Ventas Detalladas',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableCell('Fecha', isHeader: true),
                  _buildTableCell('Vendedor', isHeader: true),
                  _buildTableCell('Total', isHeader: true),
                  _buildTableCell('Productos', isHeader: true),
                  _buildTableCell('Pago', isHeader: true),
                ],
              ),
              ...ventas.map((venta) => pw.TableRow(
                children: [
                  _buildTableCell(_dateFormat.format(venta.fecha)),
                  _buildTableCell(venta.vendedor),
                  _buildTableCell(_moneda.format(venta.total)),
                  _buildTableCell(venta.cantidadProductos.toString()),
                  _buildTableCell(_getFormaPagoEspanol(venta.formaPago)),
                ],
              )),
            ],
          ),
        ],
      );
    }

    static pw.Widget _buildInfoRow(String label, String value, {pw.TextStyle? style}) {
      return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(value, style: style),
          ],
        ),
      );
    }

    static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
      return pw.Padding(
        padding: pw.EdgeInsets.all(8),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: 10,
          ),
        ),
      );
    }

    // ==================== EXPORTAR A EXCEL ====================

    static Future<void> exportarReporteExcel({
      required ResumenVentas resumen,
      required List<VentaReporte> ventas,
      required List<ProductoTop> productosTop,
      required DateTime fechaInicio,
      required DateTime fechaFin,
    }) async {
      var excel = Excel.createExcel();

      // Hoja 1: Resumen
      var sheetResumen = excel['Resumen'];
      sheetResumen.appendRow(['ÓPTICA GÜZELLIK'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow(['REPORTE DE VENTAS'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow(['Período: ${_dateFormat.format(fechaInicio)} - ${_dateFormat.format(fechaFin)}'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow(['Fecha de generación: ${_dateTimeFormat.format(DateTime.now())}'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow([]);
      sheetResumen.appendRow(['RESUMEN DE VENTAS'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow(['Total Ventas', resumen.totalVentas].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow(['Cantidad de Ventas', resumen.cantidadVentas].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow(['Ticket Promedio', resumen.promedioVenta].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow([]);
      sheetResumen.appendRow(['DESGLOSE POR MÉTODO DE PAGO'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow(['Efectivo', resumen.efectivo].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow(['Tarjeta', resumen.tarjeta].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow(['Transferencia', resumen.transferencia].map((e) => _toCellValue(e)).toList());

      // Hoja 2: Productos más vendidos
      var sheetProductos = excel['Productos Más Vendidos'];
      sheetProductos.appendRow(['Producto', 'Cantidad Vendida', 'Total'].map((e) => TextCellValue(e)).toList());
      for (var producto in productosTop) {
        sheetProductos.appendRow([
          TextCellValue(producto.nombre),
          IntCellValue(producto.cantidadVendida),
          DoubleCellValue(producto.totalVendido)
        ]);
      }

      // Hoja 3: Ventas detalladas
      var sheetVentas = excel['Ventas Detalladas'];
      sheetVentas.appendRow(['Fecha', 'Vendedor', 'Total', 'Productos', 'Forma de Pago'].map((e) => TextCellValue(e)).toList());
      for (var venta in ventas) {
        sheetVentas.appendRow([
          TextCellValue(_dateFormat.format(venta.fecha)),
          TextCellValue(venta.vendedor),
          DoubleCellValue(venta.total),
          IntCellValue(venta.cantidadProductos),
          TextCellValue(_getFormaPagoEspanol(venta.formaPago)),
        ]);
      }

      // Guardar archivo - Versión para WEB y Móvil/Desktop
      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('No se pudo generar el archivo Excel.');
      }

      await guardarYCompartirExcel(
        bytes,
        'reporte_ventas_${_dateFormat.format(DateTime.now())}.xlsx',
        'Reporte de Ventas ${_dateFormat.format(fechaInicio)} - ${_dateFormat.format(fechaFin)}',
      );
    }

    // Función auxiliar para convertir a CellValue
    static CellValue _toCellValue(dynamic value) {
      if (value is String) {
        return TextCellValue(value);
      } else if (value is int) {
        return IntCellValue(value);
      } else if (value is double) {
        return DoubleCellValue(value);
      } else if (value is num) {
        return DoubleCellValue(value.toDouble());
      } else {
        return TextCellValue(value.toString());
      }
    }

    // ==================== EXPORTAR INVENTARIO ====================

    static pw.Widget _buildHeaderInventario(Uint8List? logoBytes) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoBytes != null)
                pw.Container(
                  width: 60,
                  height: 60,
                  child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
                )
              else
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Icon(pw.IconData(0xe3c9), color: PdfColors.grey500),
                ),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Óptica Güzellik',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                  pw.Text(
                    'Reporte de Inventario',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Corte al: ${_dateTimeFormat.format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
        ],
      );
    }

    static pw.Widget _buildResumenInventario(List<Producto> activos, double valorCosto, double valorVenta) {
      final unidades = activos.fold<int>(0, (s, p) => s + p.stock);
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumen',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                _buildInfoRow('Productos activos', activos.length.toString()),
                _buildInfoRow('Unidades totales en stock', unidades.toString()),
                pw.SizedBox(height: 8),
                pw.Divider(),
                _buildInfoRow('Valor de inventario (a costo)', _moneda.format(valorCosto)),
                _buildInfoRow('Valor de inventario (a precio de venta)', _moneda.format(valorVenta)),
                _buildInfoRow('Ganancia potencial', _moneda.format(valorVenta - valorCosto)),
              ],
            ),
          ),
        ],
      );
    }

    static pw.Widget _buildTablaInventario(List<Producto> productos) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Detalle por producto',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(1.4),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1.5),
              4: pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildTableCell('Producto', isHeader: true),
                  _buildTableCell('Código', isHeader: true),
                  _buildTableCell('Stock', isHeader: true),
                  _buildTableCell('Valor costo', isHeader: true),
                  _buildTableCell('Valor venta', isHeader: true),
                ],
              ),
              ...productos.map((p) => pw.TableRow(
                    children: [
                      _buildTableCell(p.nombre),
                      _buildTableCell(p.codigo),
                      _buildTableCell(p.stock.toString()),
                      _buildTableCell(_moneda.format(p.stock * p.precioCompra)),
                      _buildTableCell(_moneda.format(p.stock * p.precioVenta)),
                    ],
                  )),
            ],
          ),
        ],
      );
    }

    /// Exporta el inventario actual (todos los productos activos) a PDF, con valorización.
    static Future<void> exportarInventarioPDF({required List<Producto> productos}) async {
      try {
        final pdf = pw.Document();
        final logoBytes = await _cargarLogo();
        final activos = productos.where((p) => p.activo).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        final valorCosto = activos.fold<double>(0, (s, p) => s + p.stock * p.precioCompra);
        final valorVenta = activos.fold<double>(0, (s, p) => s + p.stock * p.precioVenta);

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(20),
            build: (pw.Context context) => [
              _buildHeaderInventario(logoBytes),
              pw.SizedBox(height: 20),
              _buildResumenInventario(activos, valorCosto, valorVenta),
              pw.SizedBox(height: 20),
              _buildTablaInventario(activos),
              pw.SizedBox(height: 30),
              _buildFooter(),
            ],
          ),
        );

        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'inventario_${_dateFormat.format(DateTime.now())}.pdf',
        );
      } catch (e) {
        rethrow;
      }
    }

    /// Exporta el inventario actual (todos los productos activos) a Excel, con valorización.
    static Future<void> exportarInventarioExcel({required List<Producto> productos}) async {
      var excel = Excel.createExcel();
      final activos = productos.where((p) => p.activo).toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));
      final valorCosto = activos.fold<double>(0, (s, p) => s + p.stock * p.precioCompra);
      final valorVenta = activos.fold<double>(0, (s, p) => s + p.stock * p.precioVenta);
      final unidades = activos.fold<int>(0, (s, p) => s + p.stock);

      var sheetResumen = excel['Resumen'];
      sheetResumen.appendRow(['ÓPTICA GÜZELLIK'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow(['REPORTE DE INVENTARIO'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow(['Corte al: ${_dateTimeFormat.format(DateTime.now())}'].map((e) => TextCellValue(e)).toList());
      sheetResumen.appendRow([]);
      sheetResumen.appendRow(['Productos activos', activos.length].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow(['Unidades totales en stock', unidades].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow(['Valor de inventario (a costo)', valorCosto].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow(['Valor de inventario (a precio de venta)', valorVenta].map((e) => _toCellValue(e)).toList());
      sheetResumen.appendRow(['Ganancia potencial', valorVenta - valorCosto].map((e) => _toCellValue(e)).toList());

      var sheetDetalle = excel['Detalle'];
      sheetDetalle.appendRow([
        'Código', 'Nombre', 'Tipo', 'Marca', 'Stock', 'Stock mínimo',
        'Costo unitario', 'Precio venta unitario', 'Valor costo', 'Valor venta',
      ].map((e) => TextCellValue(e)).toList());
      for (var p in activos) {
        sheetDetalle.appendRow([
          TextCellValue(p.codigo),
          TextCellValue(p.nombre),
          TextCellValue(p.tipoEnEspanol),
          TextCellValue(p.marca),
          IntCellValue(p.stock),
          IntCellValue(p.stockMinimo),
          DoubleCellValue(p.precioCompra),
          DoubleCellValue(p.precioVenta),
          DoubleCellValue(p.stock * p.precioCompra),
          DoubleCellValue(p.stock * p.precioVenta),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) {
        throw Exception('No se pudo generar el archivo Excel.');
      }

      await guardarYCompartirExcel(
        bytes,
        'inventario_${_dateFormat.format(DateTime.now())}.xlsx',
        'Reporte de Inventario - ${_dateFormat.format(DateTime.now())}',
      );
    }

    // ==================== EXPORTAR CAJA ====================

    static Future<void> exportarCorteCajaPDF({
      required double montoInicial,
      required double totalVentas,
      required double efectivo,
      required double tarjeta,
      required double transferencia,
      required double totalGastos,
      required double esperado,
      required double real,
      required double diferencia,
      required DateTime fechaApertura,
      required DateTime fechaCierre,
      required String empleado,
      required List<Map<String, dynamic>> ventasDelDia,
      required List<Map<String, dynamic>> gastos,
    }) async {
      try {
        
        final pdf = pw.Document();
        final logoBytes = await _cargarLogo();

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(20),
            build: (pw.Context context) => [
              // Encabezado con logo
              _buildHeaderCorte(logoBytes, fechaCierre, empleado),
              pw.SizedBox(height: 20),

              // Resumen
              pw.Text(
                'Resumen del Turno',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Apertura', _dateTimeFormat.format(fechaApertura)),
              _buildInfoRow('Cierre', _dateTimeFormat.format(fechaCierre)),
              _buildInfoRow('Monto Inicial', _moneda.format(montoInicial)),
              pw.Divider(),
              _buildInfoRow('Total Ventas', _moneda.format(totalVentas)),
              _buildInfoRow('Efectivo', _moneda.format(efectivo)),
              _buildInfoRow('Tarjeta', _moneda.format(tarjeta)),
              _buildInfoRow('Transferencia', _moneda.format(transferencia)),
              pw.Divider(),
              _buildInfoRow('Total Gastos', _moneda.format(totalGastos)),
              pw.Divider(thickness: 2),
              _buildInfoRow('Esperado', _moneda.format(esperado)),
              _buildInfoRow('Real', _moneda.format(real)),
              _buildInfoRow(
                'Diferencia', 
                _moneda.format(diferencia),
                style: pw.TextStyle(
                  color: diferencia >= 0 ? PdfColors.green : PdfColors.red,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Ventas del día
              if (ventasDelDia.isNotEmpty) ...[
                pw.Text(
                  'Ventas Realizadas',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        _buildTableCell('Hora', isHeader: true),
                        _buildTableCell('Cliente', isHeader: true),
                        _buildTableCell('Total', isHeader: true),
                        _buildTableCell('Pago', isHeader: true),
                      ],
                    ),
                    ...ventasDelDia.map((venta) => pw.TableRow(
                      children: [
                        _buildTableCell(venta['hora']?.toString() ?? ''),
                        _buildTableCell(venta['cliente']?.toString() ?? 'Cliente general'),
                        _buildTableCell(_moneda.format(venta['total'] ?? 0.0)),
                        _buildTableCell(_getFormaPagoEspanol(venta['formaPago']?.toString() ?? 'efectivo')),
                      ],
                    )),
                  ],
                ),
              ],

              // Gastos del día
              if (gastos.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  'Gastos Registrados',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        _buildTableCell('Concepto', isHeader: true),
                        _buildTableCell('Monto', isHeader: true),
                        _buildTableCell('Forma de Pago', isHeader: true),
                      ],
                    ),
                    ...gastos.map((gasto) => pw.TableRow(
                      children: [
                        _buildTableCell(gasto['concepto']?.toString() ?? ''),
                        _buildTableCell(_moneda.format(gasto['monto'] ?? 0.0)),
                        _buildTableCell(_getFormaPagoEspanol(gasto['formaPago']?.toString() ?? 'efectivo')),
                      ],
                    )),
                  ],
                ),
              ],
              
              // Pie de página
              pw.SizedBox(height: 30),
              _buildFooter(),
            ],
          ),
        );

        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'corte_caja_${_dateFormat.format(fechaCierre)}.pdf',
        );
        
      } catch (e) {
        rethrow;
      }
    }

    static pw.Widget _buildHeaderCorte(Uint8List? logoBytes, DateTime fechaCierre, String empleado) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo con manejo seguro
              if (logoBytes != null)
                pw.Container(
                  width: 60,
                  height: 60,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Icon(pw.IconData(0xe3c9), color: PdfColors.grey500),
                ),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Óptica Güzellik',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    'Corte de Caja',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            'Fecha: ${_dateFormat.format(fechaCierre)}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.Text(
            'Empleado: ${empleado.isEmpty ? "No especificado" : empleado}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
        ],
      );
    }

    // Función auxiliar para obtener el nombre del método de pago en español
    static String _getFormaPagoEspanol(String formaPago) {
      switch (formaPago) {
        case 'efectivo':
          return 'Efectivo';
        case 'tarjeta':
          return 'Tarjeta';
        case 'transferencia':
          return 'Transferencia';
        case 'mixto':
          return 'Mixto';
        default:
          return formaPago;
      }
    }


    // ==================== EXPORTAR TICKET TÉRMICO ====================

    /// Genera un ticket térmico en formato PDF (80mm)
    static Future<void> generarTicket({
      required String folio,
      required DateTime fecha,
      required String vendedor,
      required String? pacienteNombre,
      required String? pacienteTelefono,
      required List<dynamic> productos,
      required double subtotal,
      required double descuentoTotal,
      required double total,
      required double anticipo,
      required double saldoPendiente,
      double cambio = 0,
      required String formaPago,
      required Map<String, dynamic>? detallePagoMixto,
      required DateTime? fechaEntrega,
      required String estado,
      required String? notas,
    }) async {
      try {

        final pdf = pw.Document();
        final logoBytes = await _cargarLogo();

        final alturaEstimada = _estimarAlturaTicket(
          tieneLogo: logoBytes != null,
          tienePaciente: pacienteNombre != null && pacienteNombre.isNotEmpty,
          tieneTelefonoPaciente: pacienteTelefono != null && pacienteTelefono.isNotEmpty,
          cantidadProductos: productos.length,
          productosConGraduacion:
              productos.where((p) => p['graduacion'] != null).length,
          tieneDescuento: descuentoTotal > 0,
          formaPago: formaPago,
          detallePagoMixto: detallePagoMixto,
          tieneSaldoPendiente: saldoPendiente > 0,
          tieneCambio: cambio > 0,
          tieneFechaEntrega: fechaEntrega != null,
          notas: notas,
        );

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat(
              283,  // 80mm en puntos (1mm = 3.54 puntos)
              alturaEstimada,
              marginAll: 8,
            ),
            build: (pw.Context context) => [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Logo
                  if (logoBytes != null)
                    pw.Container(
                      height: 50,
                      width: 50,
                      child: pw.Image(
                        pw.MemoryImage(logoBytes),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  
                  pw.SizedBox(height: 4),
                  
                  // Nombre de la óptica
                  pw.Text(
                    'ÓPTICA GÜZELLIK',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Pasión por cuidar tus ojos',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'Tel: (418) 1776021',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'Av. sur núm 8 interior 4 entre calle Hidalgo y Yucatán',
                    style: pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),

                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 1),
                  
                  // Título del ticket
                  pw.Text(
                    'TICKET DE VENTA',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  
                  pw.SizedBox(height: 4),
                  
                  // Información de la venta
                  _buildTicketRow('Folio:', folio),
                  _buildTicketRow('Fecha:', _dateTimeFormat.format(fecha)),
                  _buildTicketRow('Vendedor:', vendedor),
                  
                  pw.SizedBox(height: 4),
                  
                  // Información del cliente
                  if (pacienteNombre != null && pacienteNombre.isNotEmpty) ...[
                    pw.Divider(thickness: 0.5),
                    pw.Text(
                      'DATOS DEL CLIENTE',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    _buildTicketRow('Nombre:', pacienteNombre),
                    if (pacienteTelefono != null && pacienteTelefono.isNotEmpty)
                      _buildTicketRow('Teléfono:', pacienteTelefono),
                  ],
                  
                  pw.Divider(thickness: 0.5),
                  
                  // Productos
                  pw.Text(
                    'PRODUCTOS',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  
                  // Encabezado de productos
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text('Producto', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('Cant', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('Precio', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('Desc.', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 2),

                  // Lista de productos
                  ...productos.map((item) {
                    final nombre = item['nombre'] ?? 'Producto';
                    final cantidad = item['cantidad'] ?? 1;
                    final precioUnitario = (item['precio_unitario'] ?? 0).toDouble();
                    final descuentoItem = (item['descuento'] ?? 0).toDouble();
                    final bruto = precioUnitario * (cantidad is num ? cantidad : 1);
                    final pctDescuento = bruto > 0 ? (descuentoItem / bruto * 100) : 0.0;

                    return pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(
                                nombre.length > 20 ? '${nombre.substring(0, 20)}...' : nombre,
                                style: pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                cantidad.toString(),
                                style: pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                _moneda.format(precioUnitario),
                                style: pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                descuentoItem > 0 ? '${pctDescuento.toStringAsFixed(0)}%' : '',
                                style: pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        if (item['graduacion'] != null) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            '  Graduación: ${_formatGraduacion(item['graduacion'])}',
                            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                          ),
                        ],
                      ],
                    );
                  }).toList(),
                  
                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 0.5),
                  
                  // Totales
                  _buildTicketRow('SUBTOTAL:', _moneda.format(subtotal), isBold: true),
                  if (descuentoTotal > 0)
                    _buildTicketRow('DESCUENTO:', '-${_moneda.format(descuentoTotal)}', isBold: true),
                  _buildTicketRow('TOTAL:', _moneda.format(total), isBold: true, isTotal: true),
                  
                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 0.5),
                  
                  // Información de pago
                  pw.Text(
                    'INFORMACIÓN DE PAGO',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  _buildTicketRow('Forma de pago:', _getFormaPagoEspanol(formaPago)),
                  
                  if (formaPago == 'mixto' && detallePagoMixto != null) ...[
                    if (detallePagoMixto['efectivo'] > 0)
                      _buildTicketRow('  Efectivo:', _moneda.format(detallePagoMixto['efectivo'])),
                    if (detallePagoMixto['tarjeta'] > 0)
                      _buildTicketRow('  Tarjeta:', _moneda.format(detallePagoMixto['tarjeta'])),
                    if (detallePagoMixto['transferencia'] > 0)
                      _buildTicketRow('  Transferencia:', _moneda.format(detallePagoMixto['transferencia'])),
                  ],
                  
                  _buildTicketRow('Anticipo:', _moneda.format(anticipo)),
                  if (saldoPendiente > 0)
                    _buildTicketRow('Pendiente por pagar:', _moneda.format(saldoPendiente), isSaldo: true, destacado: true),
                  if (cambio > 0)
                    _buildTicketRow('Cambio:', _moneda.format(cambio), isCambio: true, destacado: true),


                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 0.5),
                  
                  // Fecha de entrega
                  if (fechaEntrega != null) ...[
                    _buildTicketRow('Fecha de entrega:', _dateFormat.format(fechaEntrega)),
                  ],
                  
                  // Estado
                  _buildTicketRow('Estado:', _getEstadoEspanol(estado)),
                  
                  // Notas
                  if (notas != null && notas.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'NOTAS:',
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      notas,
                      style: pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                  
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 0.5),
                  
                  // Mensaje de agradecimiento y avisos legales
                  pw.Text(
                    '¡GRACIAS POR SU COMPRA!',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Este documento no es un comprobante fiscal.',
                    style: pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'No aplica devoluciones o reembolsos en cancelaciones de trabajos.',
                    style: pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Después de 30 días Visual Güzellik no se hace responsable de ningún trabajo.',
                    style: pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Garantías aplican únicamente por defecto del producto o materiales adquiridos.',
                    style: pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );

        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: 'ticket_${folio}_${_dateFormat.format(DateTime.now())}.pdf',
        );
        
      } catch (e) {
       
        rethrow;
      }
    }

    /// Estima la altura (en puntos) que ocupará el ticket según su contenido
    /// real. El paquete `pdf` exige una altura de página finita (no acepta
    /// double.infinity), así que en vez de usar un alto fijo -que siempre
    /// imprimía la misma longitud completa aunque el ticket fuera corto,
    /// desperdiciando papel- se calcula un estimado a partir de lo que
    /// realmente se va a imprimir (cantidad de productos, si hay paciente,
    /// notas, etc.). Los números son aproximados a propósito por exceso,
    /// para no volver a cortar contenido como pasaba con la altura fija.
    static double _estimarAlturaTicket({
      required bool tieneLogo,
      required bool tienePaciente,
      required bool tieneTelefonoPaciente,
      required int cantidadProductos,
      required int productosConGraduacion,
      required bool tieneDescuento,
      required String formaPago,
      required Map<String, dynamic>? detallePagoMixto,
      required bool tieneSaldoPendiente,
      required bool tieneCambio,
      required bool tieneFechaEntrega,
      required String? notas,
    }) {
      double altura = 40; // márgenes + aire general

      if (tieneLogo) altura += 54;
      altura += 18 + 11 + 11 + 22; // nombre, tagline, teléfono, dirección (~2 líneas)
      altura += 8 + 9; // espacio + divisor
      altura += 16 + 4; // 'TICKET DE VENTA'
      altura += 18 * 3; // folio, fecha, vendedor
      altura += 4;

      if (tienePaciente) {
        altura += 5 + 14 + 18; // divisor + título + nombre
        if (tieneTelefonoPaciente) altura += 18;
      }

      altura += 5; // divisor
      altura += 14 + 4; // 'PRODUCTOS'
      altura += 12 + 2; // encabezado de tabla

      altura += cantidadProductos * 16;
      altura += productosConGraduacion * 10;

      altura += 4 + 5; // espacio + divisor
      altura += 18; // subtotal
      if (tieneDescuento) altura += 18;
      altura += 18; // total

      altura += 4 + 5; // espacio + divisor
      altura += 14; // 'INFORMACIÓN DE PAGO'
      altura += 18; // forma de pago

      if (formaPago == 'mixto' && detallePagoMixto != null) {
        if ((detallePagoMixto['efectivo'] ?? 0) > 0) altura += 18;
        if ((detallePagoMixto['tarjeta'] ?? 0) > 0) altura += 18;
        if ((detallePagoMixto['transferencia'] ?? 0) > 0) altura += 18;
      }

      altura += 18; // anticipo
      if (tieneSaldoPendiente) altura += 24; // fila destacada con borde
      if (tieneCambio) altura += 24;

      altura += 4 + 5; // espacio + divisor
      if (tieneFechaEntrega) altura += 18;
      altura += 18; // estado

      if (notas != null && notas.isNotEmpty) {
        altura += 4 + 12; // 'NOTAS:'
        final lineasEstimadas = (notas.length / 42).ceil().clamp(1, 20);
        altura += lineasEstimadas * 10;
      }

      altura += 8 + 5; // espacio + divisor
      altura += 14 + 4; // '¡GRACIAS POR SU COMPRA!'
      altura += 10 * 4; // 4 líneas de avisos legales

      return altura.clamp(260, 2500).toDouble();
    }

    static pw.Widget _buildTicketRow(String label, String value, {
      bool isBold = false,
      bool isTotal = false,
      bool isSaldo = false,
      bool isCambio = false,
      bool destacado = false,
    }) {
      final valorColor = isCambio
          ? PdfColors.green800
          : isSaldo
              ? PdfColors.orange
              : null;

      final valorTexto = pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: isTotal ? 10 : 9,
          fontWeight: pw.FontWeight.bold,
          color: destacado ? null : valorColor,
        ),
      );

      return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: isTotal ? 10 : 9,
                fontWeight: isBold || isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
            destacado
                ? pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: valorColor ?? PdfColors.black, width: 0.75),
                    ),
                    child: valorTexto,
                  )
                : valorTexto,
          ],
        ),
      );
    }

    static String _getEstadoEspanol(String estado) {
      switch (estado) {
        case 'por_enviar':
          return 'Por enviar';
        case 'laboratorio':
          return 'En laboratorio';
        case 'listo_entrega':
          return 'Listo para entrega';
        case 'entregado':
          return 'Entregado';
        case 'cancelado':
          return 'Cancelado';
        case 'garantia':
          return 'Garantía';
        case 'cortesia':
          return 'Cortesía';
        case 'reproceso':
          return 'Reproceso';
        default:
          return estado;
      }
    }

    static String _formatGraduacion(Map<String, dynamic>? graduacion) {
      if (graduacion == null) return '';
      final od = graduacion['od'];
      final oi = graduacion['oi'];
      
      if (od == null && oi == null) return '';
      
      String resultado = '';
      if (od != null) {
        resultado += 'OD: ${od['esfera'] ?? ''} ${od['cilindro'] ?? ''} ${od['eje'] ?? ''}';
      }
      if (oi != null) {
        if (resultado.isNotEmpty) resultado += ' | ';
        resultado += 'OI: ${oi['esfera'] ?? ''} ${oi['cilindro'] ?? ''} ${oi['eje'] ?? ''}';
      }
      return resultado;
    }
  }