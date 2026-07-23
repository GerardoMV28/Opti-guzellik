import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/colors.dart';
import '../../../services/venta_service.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/forms/index.dart';
import '../../../services/paciente_service.dart';
import '../../../models/pacientes/paciente_model.dart';
import '../../../models/ventas/venta_model.dart';
import '../../../services/export_service.dart';
import '../../../utils/venta_estados.dart';

class PagoScreen extends StatefulWidget {
  final List<ItemVenta> carrito;
  final double subtotal;
  final double descuentoTotal;
  final double total;

  const PagoScreen({
    Key? key,
    required this.carrito,
    required this.subtotal,
    required this.descuentoTotal,
    required this.total,
  }) : super(key: key);

  @override
  _PagoScreenState createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  bool _isLoading = false;
  
  // Datos de la venta
  String _formaPago = 'efectivo';
  double _anticipo = 0;
  double _saldoPendiente = 0;
  double _cambio = 0;
  DateTime? _fechaEntrega;
  String _estado = 'por_enviar';
  String? _pacienteId;
  String? _pacienteNombre;
  String? _pacienteTelefono;

  // Controladores para pagos
  final _montoEfectivoController = TextEditingController();
  final _montoTarjetaController = TextEditingController();
  final _montoTransferenciaController = TextEditingController();

  final _notasController = TextEditingController();

  // Búsqueda de paciente
  final _searchController = TextEditingController();
  List<Paciente> _pacientesFiltrados = [];
  bool _buscandoPaciente = false;

  final TextEditingController _descuentoGlobalController = TextEditingController();

  final NumberFormat _moneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

  double get _subtotalBruto =>
      widget.carrito.fold(0.0, (s, i) => s + i.precioUnitario * i.cantidad);

  double get _descuentoTotal =>
      widget.carrito.fold(0.0, (s, i) => s + i.descuento);

  double get _total => _subtotalBruto - _descuentoTotal;

  double _round2(double x) => double.parse(x.toStringAsFixed(2));

  void _distribuirDescuentoTotal(double montoDescuento) {
    final items = widget.carrito;
    if (items.isEmpty) return;
    final brutos = items.map((e) => e.precioUnitario * e.cantidad).toList();
    final sumB = brutos.fold(0.0, (a, b) => a + b);
    if (sumB <= 0) return;
    final m = montoDescuento.clamp(0.0, sumB);
    double asignado = 0;
    for (int i = 0; i < items.length; i++) {
      final bi = brutos[i];
      if (i == items.length - 1) {
        items[i].descuento = _round2((m - asignado).clamp(0.0, bi));
      } else {
        final d = _round2((m * bi / sumB).clamp(0.0, bi));
        items[i].descuento = d;
        asignado += d;
      }
    }
    final sumD = items.fold(0.0, (s, e) => s + e.descuento);
    final diff = _round2(m - sumD);
    if (diff.abs() >= 0.01 && items.isNotEmpty) {
      final li = items.length - 1;
      final cap = brutos[li];
      items[li].descuento =
          _round2((items[li].descuento + diff).clamp(0.0, cap));
    }
  }

  void _aplicarPorcentajeGlobal(double porcentaje) {
    if (porcentaje <= 0 || porcentaje > 100) return;
    _distribuirDescuentoTotal(_subtotalBruto * porcentaje / 100.0);
  }

  bool _aplicarMontoGlobalEscrito() {
    final raw = _descuentoGlobalController.text.replaceAll(',', '.').trim();
    final v = double.tryParse(raw) ?? 0;
    if (v < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El descuento no puede ser negativo'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    if (v > _subtotalBruto + 0.001) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El descuento no puede superar el subtotal (${_moneda.format(_subtotalBruto)})',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    _distribuirDescuentoTotal(v);
    return true;
  }

  void _quitarTodosLosDescuentos() {
    for (final e in widget.carrito) {
      e.descuento = 0;
    }
    _descuentoGlobalController.clear();
  }

  void _editarDescuentoLinea(ItemVenta item) {
    final maxDesc = item.precioUnitario * item.cantidad;
    final controller = TextEditingController(
      text: item.descuento > 0 ? item.descuento.toStringAsFixed(2) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Descuento por producto'),
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
              'Máximo: ${_moneda.format(maxDesc)}',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto a descontar en esta línea',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar')),
          TextButton(
            onPressed: () {
              final raw = controller.text.replaceAll(',', '.').trim();
              final val = double.tryParse(raw) ?? 0;
              if (val < 0 || val > maxDesc + 0.001) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'El descuento debe estar entre 0 y ${_moneda.format(maxDesc)}',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              setState(() {
                item.descuento = _round2(val);
                _recalcularSaldoInterno();
              });
              Navigator.pop(ctx);
            },
            child: Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _recalcularSaldoInterno() {
    _cambio = 0;
    if (_formaPago == 'efectivo') {
      final recibido = double.tryParse(_montoEfectivoController.text) ?? 0;
      if (recibido > _total) {
        _anticipo = _total;
        _cambio = _round2(recibido - _total);
      } else {
        _anticipo = recibido;
      }
      _saldoPendiente = _total - _anticipo;
    } else if (_formaPago == 'tarjeta') {
      _anticipo = double.tryParse(_montoTarjetaController.text) ?? 0;
      _saldoPendiente = _total - _anticipo;
    } else if (_formaPago == 'transferencia') {
      _anticipo = double.tryParse(_montoTransferenciaController.text) ?? 0;
      _saldoPendiente = _total - _anticipo;
    } else if (_formaPago == 'mixto') {
      final efectivo = double.tryParse(_montoEfectivoController.text) ?? 0;
      final tarjeta = double.tryParse(_montoTarjetaController.text) ?? 0;
      final transferencia =
          double.tryParse(_montoTransferenciaController.text) ?? 0;
      final recibidoTotal = efectivo + tarjeta + transferencia;
      if (recibidoTotal > _total) {
        // El cambio solo puede salir de lo recibido en efectivo.
        final excedente = _round2(recibidoTotal - _total);
        _cambio = excedente <= efectivo ? excedente : efectivo;
      }
      _anticipo = recibidoTotal - _cambio;
      _saldoPendiente = _total - _anticipo;
    }
    if (_saldoPendiente < 0) _saldoPendiente = 0;
  }

  @override
  void initState() {
    super.initState();
    _montoEfectivoController.addListener(_actualizarSaldo);
    _montoTarjetaController.addListener(_actualizarSaldo);
    _montoTransferenciaController.addListener(_actualizarSaldo);
    _fechaEntrega = DateTime.now().add(Duration(days: 7));
    if (_total <= 0) {
      _anticipo = 0;
      _montoEfectivoController.text = '0';
    }
    _recalcularSaldoInterno();
  }

  void _actualizarSaldo() {
    setState(_recalcularSaldoInterno);
  }

  Future<void> _buscarPacientes(String query) async {
    if (query.isEmpty) {
      setState(() {
        _pacientesFiltrados = [];
      });
      return;
    }

    setState(() {
      _buscandoPaciente = true;
    });

    try {
      final pacientes = await PacienteService.buscarPacientes(query);
      setState(() {
        _pacientesFiltrados = pacientes;
        _buscandoPaciente = false;
      });
    } catch (e) {
      setState(() {
        _buscandoPaciente = false;
      });
    }
  }

  // Función para imprimir ticket
  Future<void> _imprimirTicket(Venta venta) async {
    try {
      await ExportService.generarTicket(
        folio: venta.folio ?? venta.id?.substring(venta.id!.length - 8) ?? 'N/A',
        fecha: venta.fecha,
        vendedor: venta.vendedor,
        pacienteNombre: venta.pacienteNombre,
        pacienteTelefono: venta.pacienteTelefono,
        productos: venta.productos.map((p) => p.toJson()).toList(),
        subtotal: venta.subtotal,
        descuentoTotal: venta.descuentoTotal,
        total: venta.total,
        anticipo: venta.anticipo,
        saldoPendiente: venta.saldoPendiente,
        cambio: _cambio,
        formaPago: venta.formaPago,
        detallePagoMixto: venta.detallePagoMixto,
        fechaEntrega: venta.fechaEntrega,
        estado: venta.estado,
        notas: venta.notas,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar ticket: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mostrar diálogo de éxito con opción de imprimir ticket
  void _mostrarDialogoExito(Venta venta) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                '¡Venta Exitosa!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulReal,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La venta se ha registrado correctamente.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetalleVenta('Folio', venta.folio ?? 'N/A'),
                    _buildDetalleVenta('Total', _moneda.format(venta.total)),
                    _buildDetalleVenta('Anticipo', _moneda.format(venta.anticipo)),
                    if (venta.saldoPendiente > 0)
                      _buildDetalleVenta('Saldo pendiente', _moneda.format(venta.saldoPendiente), isSaldo: true),
                    if (_cambio > 0)
                      _buildDetalleVenta('Cambio a entregar', _moneda.format(_cambio), isSaldo: true),
                    _buildDetalleVenta('Forma de pago', _getFormaPagoEspanol(venta.formaPago)),
                    if (venta.fechaEntrega != null)
                      _buildDetalleVenta('Fecha entrega', DateFormat('dd/MM/yyyy').format(venta.fechaEntrega!)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cerrar diálogo
                Navigator.of(context).pop(true); // Regresar a ventas_screen
              },
              child: Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cerrar diálogo
                await _imprimirTicket(venta);
                if (mounted) {
                  Navigator.of(context).pop(true); // Regresar a ventas_screen
                }
              },
              icon: Icon(Icons.print, size: 18),
              label: Text('Imprimir Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.turquesa,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget auxiliar para mostrar detalles
  Widget _buildDetalleVenta(String label, String valor, {bool isSaldo = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(
            valor,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSaldo ? FontWeight.bold : FontWeight.normal,
              color: isSaldo ? Colors.orange : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormaPagoEspanol(String formaPago) {
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

  String _estadoParaGuardar() {
    if (_saldoPendiente <= 0) {
      return VentaEstados.alLiquidar(_estado);
    }
    return _estado;
  }

  Future<void> _finalizarVenta() async {
    if (widget.carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay productos en el carrito'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_total > 0 && _anticipo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingresa el monto a pagar'), backgroundColor: Colors.orange),
      );
      return;
    }

    final estadoGuardar = _estadoParaGuardar();

    setState(() => _isLoading = true);

    try {
      final user = await AuthService.getCurrentUser();
      
      final ventaData = {
        'fecha': DateTime.now().toIso8601String(),
        'vendedor': user?['nombre'] ?? 'Usuario',
        'vendedor_id': user?['id'],
        'paciente_id': _pacienteId,
        'paciente_nombre': _pacienteNombre,
        'paciente_telefono': _pacienteTelefono,
        'productos': widget.carrito.map((p) => p.toJson()).toList(),
        'subtotal': _subtotalBruto,
        'descuento_total': _descuentoTotal,
        'total': _total,
        'anticipo': _anticipo,
        'saldo_pendiente': _saldoPendiente,
        'forma_pago': _formaPago,
        'detalle_pago_mixto': _formaPago == 'mixto'
            ? {
                'efectivo': double.tryParse(_montoEfectivoController.text) ?? 0,
                'tarjeta': double.tryParse(_montoTarjetaController.text) ?? 0,
                'transferencia': double.tryParse(_montoTransferenciaController.text) ?? 0,
              }
            : null,
        'fecha_entrega': _fechaEntrega?.toIso8601String(),
        'estado': estadoGuardar,
        'historial_estados': [
          {
            'estado': estadoGuardar,
            'fecha': DateTime.now().toIso8601String(),
            'nota': _saldoPendiente <= 0 ? 'Venta pagada en su totalidad' : 'Venta registrada con anticipo',
            'actualizado_por': user?['nombre'] ?? 'Usuario',
          }
        ],
        'notas': _notasController.text.trim(),
      };

      final ventaCreada = await VentaService.createVenta(ventaData);
      
      setState(() => _isLoading = false);
      
      // Mostrar diálogo de éxito con opción de imprimir ticket
      _mostrarDialogoExito(ventaCreada);
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPanelDescuentos() {
    Widget pctBtn(double pct) {
      return OutlinedButton(
        onPressed: () {
          setState(() {
            _aplicarPorcentajeGlobal(pct);
            _recalcularSaldoInterno();
          });
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.azulReal,
          side: BorderSide(color: AppColors.turquesa.withOpacity(0.55)),
        ),
        child: Text('${pct.toStringAsFixed(0)}%'),
      );
    }

    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descuentos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.azulReal,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'El descuento global se reparte entre todas las líneas según su importe. '
            'Puedes ajustar línea por línea abajo, o seguir usando el descuento desde el carrito.',
            style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.35),
          ),
          SizedBox(height: 14),
          Text(
            'Sugeridos',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              pctBtn(5),
              pctBtn(10),
              pctBtn(15),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _quitarTodosLosDescuentos();
                    _recalcularSaldoInterno();
                  });
                },
                child: Text('Quitar descuentos'),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            'Monto fijo (toda la venta)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _descuentoGlobalController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Ej. 150.00',
                    labelText: 'Descuento en pesos',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Padding(
                padding: EdgeInsets.only(top: 6),
                child: ElevatedButton(
                  onPressed: () {
                    if (!_aplicarMontoGlobalEscrito()) return;
                    setState(_recalcularSaldoInterno);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.turquesa,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Aplicar'),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Máximo: ${_moneda.format(_subtotalBruto)}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          Divider(height: 28),
          _buildResumenRow('Subtotal venta', _moneda.format(_subtotalBruto)),
          if (_descuentoTotal > 0) ...[
            SizedBox(height: 4),
            _buildResumenRow(
              'Descuentos',
              '-${_moneda.format(_descuentoTotal)}',
            ),
          ],
          Divider(height: 20),
          _buildResumenRow('Total', _moneda.format(_total)),
          SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Por producto (${widget.carrito.length})',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.azulReal,
              ),
            ),
            children: [
              ...widget.carrito.map((item) {
                final bruto = item.precioUnitario * item.cantidad;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  title: Text(
                    item.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    'Bruto ${_moneda.format(bruto)}  ·  Desc. -${_moneda.format(item.descuento)}  ·  Neto ${_moneda.format(item.subtotal)}',
                    style: TextStyle(fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.turquesa),
                    tooltip: 'Editar descuento',
                    onPressed: () => _editarDescuentoLinea(item),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppColors.appBarGradient)),
        foregroundColor: Colors.white,
        title: Text('Finalizar Venta'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Búsqueda de paciente
                FormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o teléfono...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _buscandoPaciente
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: _buscarPacientes,
                      ),
                      if (_pacientesFiltrados.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _pacientesFiltrados.length,
                            itemBuilder: (context, index) {
                              final paciente = _pacientesFiltrados[index];
                              return ListTile(
                                title: Text(paciente.nombre),
                                subtitle: Text(paciente.telefono),
                                onTap: () {
                                  setState(() {
                                    _pacienteId = paciente.id;
                                    _pacienteNombre = paciente.nombre;
                                    _pacienteTelefono = paciente.telefono;
                                    _searchController.text = paciente.nombre;
                                    _pacientesFiltrados = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      if (_pacienteNombre != null)
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.turquesa.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.turquesa.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: AppColors.turquesa),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_pacienteNombre!),
                                    Text(_pacienteTelefono ?? ''),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _pacienteId = null;
                                    _pacienteNombre = null;
                                    _pacienteTelefono = null;
                                    _searchController.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                _buildPanelDescuentos(),

                SizedBox(height: 16),

                // Método de pago
                FormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Método de Pago',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          _buildPagoOption('efectivo', 'Efectivo', Icons.money),
                          SizedBox(width: 12),
                          _buildPagoOption('tarjeta', 'Tarjeta', Icons.credit_card),
                          SizedBox(width: 12),
                          _buildPagoOption('transferencia', 'Transferencia', Icons.account_balance),
                          SizedBox(width: 12),
                          _buildPagoOption('mixto', 'Mixto', Icons.swap_horiz),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Campos según método de pago
                      if (_formaPago == 'efectivo')
                        CustomTextField(
                          controller: _montoEfectivoController,
                          label: 'Monto en efectivo',
                          prefixIcon: Icons.money,
                          keyboardType: TextInputType.number,
                          hintText: 'Ingresa el monto recibido',
                        ),
                        
                      if (_formaPago == 'tarjeta')
                        CustomTextField(
                          controller: _montoTarjetaController,
                          label: 'Monto con tarjeta',
                          prefixIcon: Icons.credit_card,
                          keyboardType: TextInputType.number,
                          hintText: 'Ingresa el monto a pagar con tarjeta',
                        ),
                        
                      if (_formaPago == 'transferencia')
                        CustomTextField(
                          controller: _montoTransferenciaController,
                          label: 'Monto por transferencia',
                          prefixIcon: Icons.account_balance,
                          keyboardType: TextInputType.number,
                          hintText: 'Ingresa el monto a transferir',
                        ),
                        
                      if (_formaPago == 'mixto') ...[
                        CustomTextField(
                          controller: _montoEfectivoController,
                          label: 'Efectivo',
                          prefixIcon: Icons.money,
                          keyboardType: TextInputType.number,
                          hintText: 'Monto en efectivo',
                        ),
                        SizedBox(height: 8),
                        CustomTextField(
                          controller: _montoTarjetaController,
                          label: 'Tarjeta',
                          prefixIcon: Icons.credit_card,
                          keyboardType: TextInputType.number,
                          hintText: 'Monto con tarjeta',
                        ),
                        SizedBox(height: 8),
                        CustomTextField(
                          controller: _montoTransferenciaController,
                          label: 'Transferencia',
                          prefixIcon: Icons.account_balance,
                          keyboardType: TextInputType.number,
                          hintText: 'Monto por transferencia',
                        ),
                      ],
                      
                      SizedBox(height: 16),
                      Divider(),
                      _buildResumenRow('Total de la venta', _moneda.format(_total)),
                      if (_anticipo > 0) ...[
                        SizedBox(height: 4),
                        _buildResumenRow('Anticipo', _moneda.format(_anticipo)),
                      ],
                      if (_saldoPendiente > 0) ...[
                        SizedBox(height: 4),
                        _buildResumenRow('Saldo pendiente', _moneda.format(_saldoPendiente), isSaldo: true),
                      ] else if (_anticipo > 0) ...[
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text(
                                '¡Pago completado! No hay saldo pendiente.',
                                style: TextStyle(color: Colors.green, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_cambio > 0) ...[
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.turquesa.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.turquesa.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.money, color: AppColors.azulReal, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Cambio a entregar',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ],
                              ),
                              Text(
                                _moneda.format(_cambio),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.azulReal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Fecha de entrega
                FormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de Entrega',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: _fechaEntrega!,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 90)),
                          );
                          if (fecha != null) {
                            setState(() {
                              _fechaEntrega = fecha;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: AppColors.azulCobalto),
                              SizedBox(width: 12),
                              Text(
                                DateFormat('dd/MM/yyyy').format(_fechaEntrega!),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      CustomDropdown<String>(
                        value: _estado,
                        label: 'Estado del pedido',
                        icon: Icons.inventory,
                        items: [
                          DropdownMenuItem(value: 'por_enviar', child: Text('Por enviar')),
                          DropdownMenuItem(value: 'laboratorio', child: Text('En laboratorio')),
                          DropdownMenuItem(value: 'garantia', child: Text('Garantía')),
                          DropdownMenuItem(value: 'cortesia', child: Text('Cortesía')),
                          DropdownMenuItem(value: 'reproceso', child: Text('Reproceso')),
                          DropdownMenuItem(value: 'listo_entrega', child: Text('Listo para entrega')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _estado = value!;
                          });
                        },
                      ),
                      if (_saldoPendiente <= 0)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Venta liquidada: el estado se ajustará a listo para entrega si estaba en envío o laboratorio.',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Notas
                FormCard(
                  child: CustomTextField(
                    controller: _notasController,
                    label: 'Notas adicionales',
                    prefixIcon: Icons.note_outlined,
                    maxLines: 3,
                  ),
                ),

                SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancelar',
                        onPressed: () => Navigator.pop(context),
                        isOutlined: true,
                        color: AppColors.azulCobalto,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Realizar Venta',
                        onPressed: _finalizarVenta,
                        isLoading: _isLoading,
                        icon: Icons.check,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPagoOption(String valor, String label, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _formaPago = valor;
            _anticipo = 0;
            _saldoPendiente = _total;
            _montoEfectivoController.clear();
            _montoTarjetaController.clear();
            _montoTransferenciaController.clear();
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _formaPago == valor ? AppColors.turquesa : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _formaPago == valor ? AppColors.turquesa : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: _formaPago == valor ? Colors.white : Colors.grey[600]),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: _formaPago == valor ? Colors.white : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {bool isSaldo = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSaldo ? FontWeight.bold : FontWeight.normal,
              color: isSaldo ? Colors.orange : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _montoEfectivoController.removeListener(_actualizarSaldo);
    _montoTarjetaController.removeListener(_actualizarSaldo);
    _montoTransferenciaController.removeListener(_actualizarSaldo);
    _montoEfectivoController.dispose();
    _montoTarjetaController.dispose();
    _montoTransferenciaController.dispose();
    _notasController.dispose();
    _searchController.dispose();
    _descuentoGlobalController.dispose();
    super.dispose();
  }
}