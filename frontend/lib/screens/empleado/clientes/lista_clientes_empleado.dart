// lib/screens/empleado/clientes/lista_clientes_empleado.dart
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../models/pacientes/paciente_model.dart';
import '../../../utils/whatsapp_helper.dart';
import '../../../widgets/forms/form_card.dart';
import '../../admin/pacientes/paciente_detalle_screen.dart'; // ← Usar el detalle del admin
import 'registro_cliente_empleado.dart';

class ListaClientesEmpleado extends StatefulWidget {
  @override
  _ListaClientesEmpleadoState createState() => _ListaClientesEmpleadoState();
}

class _ListaClientesEmpleadoState extends State<ListaClientesEmpleado> {
  List<Paciente> _clientes = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final clientes = await PacienteService.getPacientes();
      setState(() {
        _clientes = clientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<Paciente> get _clientesFiltrados {
    var resultados = _clientes.where((c) => c.activo).toList();
    if (_searchQuery.isEmpty) return resultados;
    return resultados.where((c) {
      return c.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.telefono.contains(_searchQuery);
    }).toList();
  }

  void _verDetalle(Paciente cliente) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteDetalleScreen(paciente: cliente),
      ),
    );
    if (result == true) {
      _cargarClientes();
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
          'Clientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.azulReal,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.azulReal),
            onPressed: _cargarClientes,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar clientes por nombre o teléfono...',
                prefixIcon: Icon(Icons.search, color: AppColors.azulCobalto),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegistroClienteEmpleado()),
          );
          if (result == true) {
            _cargarClientes();
          }
        },
        backgroundColor: AppColors.turquesa,
        child: Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.azulReal))
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
                        onPressed: _cargarClientes,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _clientesFiltrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay clientes registrados'),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RegistroClienteEmpleado()),
                              );
                              if (result == true) {
                                _cargarClientes();
                              }
                            },
                            icon: Icon(Icons.add),
                            label: Text('Registrar Cliente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.turquesa,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _clientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final cliente = _clientesFiltrados[index];
                        return _buildClienteCard(cliente);
                      },
                    ),
    );
  }

  Widget _buildClienteCard(Paciente cliente) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: FormCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.azulCobalto,
          child: Text(
            cliente.nombre.isNotEmpty ? cliente.nombre[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          cliente.nombre,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  cliente.telefono,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '${cliente.consultas.length} consultas • ${cliente.ventas.length} compras',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.azulReal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.chat, color: Color(0xFF25D366)),
          tooltip: 'Contactar por WhatsApp',
          onPressed: () => WhatsAppHelper.contactar(
            context,
            telefono: cliente.telefono,
            nombre: cliente.nombre,
          ),
        ),
        onTap: () => _verDetalle(cliente),
      ),
      ),
    );
  }
}