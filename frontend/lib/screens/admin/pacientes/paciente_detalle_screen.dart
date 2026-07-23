import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../models/pacientes/paciente_model.dart';
import 'consulta_revision_form.dart';
import '../../../services/venta_service.dart';
import '../../../models/ventas/venta_model.dart';
import '../../../widgets/ventas/registro_abono_dialog.dart';
import '../../../services/export_service.dart';
import '../../../utils/venta_estados.dart';
import 'editar_paciente_form.dart';
import '../../../utils/whatsapp_helper.dart';

class PacienteDetalleScreen extends StatefulWidget {
  final Paciente paciente;

  PacienteDetalleScreen({required this.paciente});

  @override
  _PacienteDetalleScreenState createState() => _PacienteDetalleScreenState();
}

class _PacienteDetalleScreenState extends State<PacienteDetalleScreen> {
  int _selectedTab = 0;
  late Paciente _paciente;

  @override
  void initState() {
    super.initState();
    _paciente = widget.paciente;
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
        title: Text(
          'Detalle del Paciente',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Editar datos',
            onPressed: _editarPaciente,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Eliminar paciente',
            onPressed: _eliminarPaciente,
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabecera con información básica
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.azulReal, AppColors.azulCobalto],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _paciente.nombre.isNotEmpty 
                          ? _paciente.nombre[0].toUpperCase() 
                          : '?',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _paciente.nombre,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Text(
                            _paciente.telefono,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chat, color: Color(0xFF25D366)),
                  tooltip: 'Contactar por WhatsApp',
                  iconSize: 32,
                  onPressed: () => WhatsAppHelper.contactar(
                    context,
                    telefono: _paciente.telefono,
                    nombre: _paciente.nombre,
                  ),
                ),
              ],
            ),
          ),

          // Tabs de navegación
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab(0, 'Información', Icons.info_outline),
                _buildTab(1, 'Historial Clínico', Icons.medical_services_outlined),
                _buildTab(2, 'Compras', Icons.shopping_bag_outlined),
              ],
            ),
          ),

          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: _nuevaRevision,
              label: Text('Nueva Revisión'),
              icon: Icon(Icons.add),
              backgroundColor: AppColors.turquesa,
            )
          : null,
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.turquesa : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.turquesa : Colors.grey,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.turquesa : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildInformacion();
      case 1:
        return _buildHistorialClinico();
      case 2:
        return _buildCompras();
      default:
        return _buildInformacion();
    }
  }

  Widget _buildInformacion() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          if (_paciente.observaciones.isNotEmpty)
            _buildInfoCard(
              'Observaciones',
              _paciente.observaciones,
              Icons.note,
            ),
          SizedBox(height: 16),
          Container(
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
              children: [
                Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Consultas',
                        _paciente.consultas.length.toString(),
                        Icons.medical_services,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Compras',
                        _paciente.ventas.length.toString(),
                        Icons.shopping_bag,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Desde',
                        _formatDate(_paciente.fechaRegistro),
                        Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialClinico() {
    if (_paciente.consultas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay consultas registradas', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('El paciente aún no tiene historial clínico', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _paciente.consultas.length,
      itemBuilder: (context, index) {
        final consulta = _paciente.consultas[index];
        return _buildConsultaCard(consulta);
      },
    );
  }

  Widget _buildCompras() {
    if (_paciente.ventas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay compras registradas', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return FutureBuilder<List<Venta>>(
      future: _cargarVentas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Error al cargar ventas'),
                Text(snapshot.error.toString()),
              ],
            ),
          );
        }
        
        final ventas = snapshot.data ?? [];
        
        if (ventas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay compras registradas'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: ventas.length,
          itemBuilder: (context, index) {
            final venta = ventas[index];
            return _buildVentaCard(venta);
          },
        );
      },
    );
  }

  Future<List<Venta>> _cargarVentas() async {
    List<Venta> ventas = [];
    for (final ventaId in _paciente.ventas) {
      try {
        final venta = await VentaService.getVentaById(ventaId);
        ventas.add(venta);
      } catch (e) {
        print('Error cargando venta $ventaId: $e');
      }
    }
    ventas.sort((a, b) => b.fecha.compareTo(a.fecha));
    return ventas;
  }

  Widget _buildVentaCard(Venta venta) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.azulCobalto.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt, color: AppColors.azulCobalto),
        ),
        title: Text(
          'Venta #${venta.id?.substring(venta.id!.length - 6) ?? '---'}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${_formatDate(venta.fecha)}'),
            Text('Total: \$${venta.total.toStringAsFixed(2)}'),
            Text('Estado: ${VentaEstados.etiqueta(venta.estado)}'),
            Text('${venta.productos.length} producto(s)'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de ticket
            IconButton(
              icon: Icon(Icons.receipt, color: AppColors.azulCobalto),
              onPressed: () => _imprimirTicket(venta),
              tooltip: 'Imprimir ticket',
            ),
            // Dropdown para cambiar estado
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: VentaEstados.color(venta.estado).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: VentaEstados.color(venta.estado)),
              ),
              child: DropdownButton<String>(
                value: venta.estado,
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                underline: SizedBox(),
                dropdownColor: AppColors.azulReal,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                onChanged: (nuevoEstado) async {
                  try {
                    await VentaService.updateEstado(
                      venta.id!,
                      nuevoEstado!,
                      'Estado actualizado por usuario',
                    );
                    _recargarPaciente();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Estado actualizado a ${VentaEstados.etiqueta(nuevoEstado)}'),
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
                },
                items: [
                  DropdownMenuItem(
                    value: 'por_enviar',
                    child: Row(
                      children: [
                        Icon(Icons.inventory, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Por enviar'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'laboratorio',
                    child: Row(
                      children: [
                        Icon(Icons.science, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('En laboratorio'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'listo_entrega',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Listo para entrega'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'garantia',
                    child: Row(
                      children: [
                        Icon(Icons.verified_user, size: 16, color: Colors.teal),
                        SizedBox(width: 8),
                        Text('Garantía'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'cortesia',
                    child: Row(
                      children: [
                        Icon(Icons.card_giftcard, size: 16, color: Colors.pink),
                        SizedBox(width: 8),
                        Text('Cortesía'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'reproceso',
                    child: Row(
                      children: [
                        Icon(Icons.autorenew, size: 16, color: Colors.deepOrange),
                        SizedBox(width: 8),
                        Text('Reproceso'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'entregado',
                    child: Row(
                      children: [
                        Icon(Icons.delivery_dining, size: 16, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Entregado'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'cancelado',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cancelado'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => _mostrarDetalleVenta(venta),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleVenta(Venta venta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Barra superior con dropdown de estado y botón de ticket
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.azulReal,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detalle de Venta',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Folio: ${venta.folio ?? venta.id?.substring(venta.id!.length - 8) ?? '---'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón de ticket
                      IconButton(
                        icon: Icon(Icons.receipt, color: Colors.white),
                        onPressed: () => _imprimirTicket(venta),
                        tooltip: 'Imprimir ticket',
                      ),
                      // Dropdown de estado
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: VentaEstados.color(venta.estado).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: VentaEstados.color(venta.estado)),
                        ),
                        child: DropdownButton<String>(
                          value: venta.estado,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                          underline: SizedBox(),
                          dropdownColor: AppColors.azulReal,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          onChanged: (nuevoEstado) async {
                            try {
                              await VentaService.updateEstado(
                                venta.id!,
                                nuevoEstado!,
                                'Estado actualizado por usuario',
                              );
                              setModalState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Estado actualizado a ${VentaEstados.etiqueta(nuevoEstado)}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _recargarPaciente();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al actualizar estado: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'por_enviar',
                              child: Row(
                                children: [
                                  Icon(Icons.inventory, size: 16, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Por enviar'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'laboratorio',
                              child: Row(
                                children: [
                                  Icon(Icons.science, size: 16, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('En laboratorio'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'listo_entrega',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Listo para entrega'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'garantia',
                              child: Row(
                                children: [
                                  Icon(Icons.verified_user, size: 16, color: Colors.teal),
                                  SizedBox(width: 8),
                                  Text('Garantía'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'cortesia',
                              child: Row(
                                children: [
                                  Icon(Icons.card_giftcard, size: 16, color: Colors.pink),
                                  SizedBox(width: 8),
                                  Text('Cortesía'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'reproceso',
                              child: Row(
                                children: [
                                  Icon(Icons.autorenew, size: 16, color: Colors.deepOrange),
                                  SizedBox(width: 8),
                                  Text('Reproceso'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'entregado',
                              child: Row(
                                children: [
                                  Icon(Icons.delivery_dining, size: 16, color: Colors.purple),
                                  SizedBox(width: 8),
                                  Text('Entregado'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'cancelado',
                              child: Row(
                                children: [
                                  Icon(Icons.cancel, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Cancelado'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido con tabs
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.grey[100],
                          child: TabBar(
                            labelColor: AppColors.azulReal,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppColors.turquesa,
                            tabs: const [
                              Tab(text: 'Información'),
                              Tab(text: 'Productos'),
                              Tab(text: 'Pago'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildVentaInfoTab(venta),
                              _buildVentaProductosTab(venta),
                              _buildVentaPagoTab(venta, setModalState),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVentaInfoTab(Venta venta) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVentaInfoRow('Fecha', _formatDateTime(venta.fecha)),
          const Divider(),
          _buildVentaInfoRow('Vendedor', venta.vendedor),
          const Divider(),
          _buildVentaInfoRow('Cliente', venta.pacienteNombre ?? 'Cliente general'),
          const Divider(),
          _buildVentaInfoRow('Teléfono', venta.pacienteTelefono ?? 'No registrado'),
          const Divider(),
          _buildVentaInfoRow('Fecha de entrega',
            venta.fechaEntrega != null 
              ? _formatDate(venta.fechaEntrega!) 
              : 'No especificada'),
          const Divider(),
          if (venta.notas != null && venta.notas!.isNotEmpty)
            _buildVentaInfoRow('Notas', venta.notas!),
        ],
      ),
    );
  }

  Widget _buildVentaProductosTab(Venta venta) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: venta.productos.length,
      itemBuilder: (context, index) {
        final item = venta.productos[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Código: ${item.codigo}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Precio unitario: \$${item.precioUnitario.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'x${item.cantidad}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVentaPagoTab(Venta venta, StateSetter setModalState) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Resumen financiero
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildResumenRow('Subtotal', '\$${venta.subtotal.toStringAsFixed(2)}'),
                  _buildResumenRow('Descuento', '-\$${venta.descuentoTotal.toStringAsFixed(2)}'),
                  Divider(),
                  _buildResumenRow('Total', '\$${venta.total.toStringAsFixed(2)}', isTotal: true),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildResumenRow('Anticipo', '\$${venta.anticipo.toStringAsFixed(2)}'),
                        _buildResumenRow('Saldo pendiente', '\$${venta.saldoPendiente.toStringAsFixed(2)}', isSaldo: true),
                      ],
                    ),
                  ),
                  if (venta.saldoPendiente > 0) ...[
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: () => _mostrarDialogoAbono(venta),
                        icon: Icon(Icons.payment, size: 18),
                        label: Text('Registrar Abono'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.turquesa,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Método de pago original
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Método de Pago',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.azulReal,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getPagoColor(venta.formaPago).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getPagoIcon(venta.formaPago),
                          color: _getPagoColor(venta.formaPago),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        _getPagoEspanol(venta.formaPago),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (venta.detallePagoMixto != null) ...[
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 8),
                    Text(
                      'Detalle del pago mixto:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    if (venta.detallePagoMixto!['efectivo'] != null && venta.detallePagoMixto!['efectivo']! > 0)
                      _buildResumenRow('Efectivo', '\$${venta.detallePagoMixto!['efectivo']!.toStringAsFixed(2)}'),
                    if (venta.detallePagoMixto!['tarjeta'] != null && venta.detallePagoMixto!['tarjeta']! > 0)
                      _buildResumenRow('Tarjeta', '\$${venta.detallePagoMixto!['tarjeta']!.toStringAsFixed(2)}'),
                    if (venta.detallePagoMixto!['transferencia'] != null && venta.detallePagoMixto!['transferencia']! > 0)
                      _buildResumenRow('Transferencia', '\$${venta.detallePagoMixto!['transferencia']!.toStringAsFixed(2)}'),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Historial de abonos - CORREGIDO
          if (venta.historialAbonos != null && venta.historialAbonos!.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history, color: AppColors.azulCobalto),
                        SizedBox(width: 8),
                        Text(
                          'Historial de Abonos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.azulReal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ...venta.historialAbonos!.map((abono) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: _getPagoColor(abono['forma_pago']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.payments,
                                color: _getPagoColor(abono['forma_pago']),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${(abono['monto'] as num).toDouble().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: _getPagoColor(abono['forma_pago']),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // ✅ CORREGIDO: Manejar fecha si es DateTime o String
                                  Text(
                                    _formatFechaSegura(abono['fecha']),
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getPagoColor(abono['forma_pago']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getPagoEspanol(abono['forma_pago']),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _getPagoColor(abono['forma_pago']),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (abono['registrado_por'] != null) ...[
                                        SizedBox(width: 8),
                                        Text(
                                          'Por: ${abono['registrado_por']}',
                                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (abono['nota'] != null && abono['nota'].isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      abono['nota'],
                                      style: TextStyle(fontSize: 11, color: AppColors.azulCobalto),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    Divider(),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.turquesa.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total abonado:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$${venta.anticipo.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.turquesa,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          SizedBox(height: 16),
          
          // Historial de estados - CORREGIDO
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline, color: AppColors.azulCobalto),
                      SizedBox(width: 8),
                      Text(
                        'Historial de Estados',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.azulReal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...venta.historialEstados.map((estado) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: VentaEstados.color(estado['estado']),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                VentaEstados.etiqueta(estado['estado']),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              // ✅ CORREGIDO: Manejar fecha si es DateTime o String
                              Text(
                                estado['fecha'] != null 
                                    ? _formatFechaSegura(estado['fecha']) 
                                    : '',
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                              if (estado['nota'] != null && estado['nota'].isNotEmpty)
                                Text(
                                  estado['nota'],
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NUEVA FUNCIÓN AUXILIAR para formatear fechas de forma segura
  String _formatFechaSegura(dynamic fecha) {
    if (fecha == null) return '';
    if (fecha is DateTime) return _formatDateTime(fecha);
    if (fecha is String) {
      try {
        return _formatDateTime(DateTime.parse(fecha));
      } catch (e) {
        return fecha;
      }
    }
    return '';
  }

  Color _getPagoColor(String formaPago) {
    switch (formaPago) {
      case 'efectivo':
        return Colors.green;
      case 'tarjeta':
        return Colors.blue;
      case 'transferencia':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _mostrarDialogoAbono(Venta venta) {
    showDialog(
      context: context,
      builder: (context) => RegistroAbonoDialog(
        ventaId: venta.id!,
        saldoPendiente: venta.saldoPendiente,
        onAbonoRegistrado: () {
          _recargarPaciente();
        },
      ),
    );
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

  Widget _buildVentaInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String value, {bool isTotal = false, bool isSaldo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              color: isSaldo ? Colors.orange : (isTotal ? AppColors.azulReal : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String titulo, String contenido, IconData icon) {
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.azulCobalto.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.azulCobalto),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contenido,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.azulCobalto, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.azulReal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildConsultaCard(Consulta consulta) {
    // Usa el flag explícito cuando está disponible; si no (consultas creadas
    // antes de que el backend lo guardara), recurre a la heurística anterior.
    final esPrimeraConsulta = consulta.esRevision
        ? false
        : (consulta.rxAnterior != null ||
            consulta.sintomas != null ||
            consulta.antecedentes != null);
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: esPrimeraConsulta 
                ? AppColors.turquesa.withOpacity(0.1)
                : AppColors.azulCobalto.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${consulta.fecha.day}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: esPrimeraConsulta 
                      ? AppColors.turquesa
                      : AppColors.azulCobalto,
                ),
              ),
              Text(
                _getMonthAbbreviation(consulta.fecha.month),
                style: TextStyle(
                  fontSize: 10,
                  color: esPrimeraConsulta 
                      ? AppColors.turquesa
                      : AppColors.azulCobalto,
                ),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Text(
              esPrimeraConsulta ? 'Consulta Inicial' : 'Revisión',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.azulReal,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: esPrimeraConsulta 
                    ? AppColors.turquesa.withOpacity(0.1)
                    : AppColors.azulCobalto.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                consulta.especialista,
                style: TextStyle(
                  fontSize: 10,
                  color: esPrimeraConsulta 
                      ? AppColors.turquesa
                      : AppColors.azulCobalto,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          consulta.motivoConsulta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (consulta.diagnostico.isNotEmpty)
                  _buildDetailRow('Diagnóstico', consulta.diagnostico),
                if (consulta.graduacionFinal.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Graduación Final',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulReal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('OD', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('Esfera: ${consulta.graduacionFinal['od']?['esfera'] ?? '-'}'),
                              Text('Cilindro: ${consulta.graduacionFinal['od']?['cilindro'] ?? '-'}'),
                              Text('Eje: ${consulta.graduacionFinal['od']?['eje'] ?? '-'}'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('OI', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('Esfera: ${consulta.graduacionFinal['oi']?['esfera'] ?? '-'}'),
                              Text('Cilindro: ${consulta.graduacionFinal['oi']?['cilindro'] ?? '-'}'),
                              Text('Eje: ${consulta.graduacionFinal['oi']?['eje'] ?? '-'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (consulta.rxFinal != null && consulta.rxFinal!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'RX Final',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulReal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('OD', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('Esfera: ${consulta.rxFinal!['od']?['esf'] ?? '-'}'),
                              Text('Cilindro: ${consulta.rxFinal!['od']?['cil'] ?? '-'}'),
                              Text('Eje: ${consulta.rxFinal!['od']?['eje'] ?? '-'}'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('OI', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('Esfera: ${consulta.rxFinal!['oi']?['esf'] ?? '-'}'),
                              Text('Cilindro: ${consulta.rxFinal!['oi']?['cil'] ?? '-'}'),
                              Text('Eje: ${consulta.rxFinal!['oi']?['eje'] ?? '-'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (consulta.recomendaciones.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('Recomendaciones', consulta.recomendaciones),
                ],
                if (consulta.productosRecetados.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Productos recetados: ${consulta.productosRecetados.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.azulCobalto,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.azulReal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(height: 1.5),
        ),
      ],
    );
  }

  void _nuevaRevision() async {
    String tipoPaciente = 'adulto';
    
    if (_paciente.consultas.isNotEmpty) {
      tipoPaciente = _paciente.consultas.first.tipoPaciente;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultaRevisionForm(
          pacienteId: _paciente.id,
          tipoPaciente: tipoPaciente,
        ),
      ),
    );
    
    if (result == true) {
      _recargarPaciente();
    }
  }

  Future<void> _editarPaciente() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarPacienteForm(paciente: _paciente),
      ),
    );
    if (result == true) {
      _recargarPaciente();
    }
  }

  Future<void> _eliminarPaciente() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Paciente'),
        content: Text('¿Estás seguro de eliminar a ${_paciente.nombre}?'),
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

    if (confirm != true) return;

    try {
      await PacienteService.deletePaciente(_paciente.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paciente eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _recargarPaciente() async {
    try {
      final pacienteActualizado = await PacienteService.getPacienteById(_paciente.id);
      setState(() {
        _paciente = pacienteActualizado;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos actualizados correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error al recargar paciente: $e');
      
      if (e.toString().contains('Sesión expirada')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sesión expirada. Por favor inicie sesión nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar los datos'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthAbbreviation(int month) {
    const months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return months[month - 1];
  }

  String _getPagoEspanol(String formaPago) {
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

  IconData _getPagoIcon(String formaPago) {
    switch (formaPago) {
      case 'efectivo':
        return Icons.money;
      case 'tarjeta':
        return Icons.credit_card;
      case 'transferencia':
        return Icons.account_balance;
      case 'mixto':
        return Icons.swap_horiz;
      default:
        return Icons.payment;
    }
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