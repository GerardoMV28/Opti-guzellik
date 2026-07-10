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
      required String formaPago,
      required Map<String, dynamic>? detallePagoMixto,
      required DateTime? fechaEntrega,
      required String estado,
      required String? notas,
    }) async {
      try {
        
        final pdf = pw.Document();
        final logoBytes = await _cargarLogo();

        // Tamaño de ticket térmico 80mm (ancho ~ 283 puntos)
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat(
              283,  // 80mm en puntos (1mm = 3.54 puntos)
              500,  // Alto dinámico
              marginAll: 8,
            ),
            build: (pw.Context context) {
              return pw.Column(
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
                    'Tu salud visual es nuestra prioridad',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'Tel: (418) 148-2482',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    'www.opticaguzellik.com',
                    style: pw.TextStyle(fontSize: 8),
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
                      pw.Text('Producto', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Cant', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Precio', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Total', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  
                  pw.SizedBox(height: 2),
                  
                  // Lista de productos
                  ...productos.map((item) {
                    final nombre = item['nombre'] ?? 'Producto';
                    final cantidad = item['cantidad'] ?? 1;
                    final precioUnitario = (item['precio_unitario'] ?? 0).toDouble();
                    final subtotalItem = (item['subtotal'] ?? 0).toDouble();
                    
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
                                _moneda.format(subtotalItem),
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
                    _buildTicketRow('Saldo pendiente:', _moneda.format(saldoPendiente), isSaldo: true),
                  
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
                  
                  // Mensaje de agradecimiento
                  pw.Text(
                    '¡GRACIAS POR SU COMPRA!',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Recuerde agendar su cita de seguimiento',
                    style: pw.TextStyle(fontSize: 7),
                  ),
                  pw.Text(
                    'www.opticaguzellik.com',
                    style: pw.TextStyle(fontSize: 7),
                  ),
                ],
              );
            },
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

    static pw.Widget _buildTicketRow(String label, String value, {
      bool isBold = false,
      bool isTotal = false,
      bool isSaldo = false,
    }) {
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
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: isTotal ? 10 : 9,
                fontWeight: isBold || isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: isSaldo ? PdfColors.orange : null,
              ),
            ),
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