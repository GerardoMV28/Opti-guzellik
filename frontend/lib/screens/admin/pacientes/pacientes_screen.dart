import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/paciente_service.dart';
import '../../../models/pacientes/paciente_model.dart';
import 'registro_paciente_consulta.dart';
import 'paciente_detalle_screen.dart'; // ← Este SÍ lo necesitas para ver detalle

class PacientesScreen extends StatefulWidget {
  @override
  _PacientesScreenState createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  List<Paciente> _pacientes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  Future<void> _cargarPacientes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pacientes = await PacienteService.getPacientes();
      setState(() {
        _pacientes = pacientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Paciente> get _pacientesFiltrados {
    if (_searchQuery.isEmpty) return _pacientes;

    final query = _searchQuery.toLowerCase().trim();
    return _pacientes.where((p) {
      return p.nombre.toLowerCase().contains(query) ||
          p.telefono.contains(query);
    }).toList();
  }

  void _nuevoPaciente() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistroPacienteConsulta()),
    );
    if (result == true) {
      _cargarPacientes();
    }
  }

  void _verDetalle(Paciente paciente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteDetalleScreen(paciente: paciente),
      ),
    );
  }

  Future<void> _eliminarPaciente(Paciente paciente) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Paciente'),
        content: Text('¿Estás seguro de eliminar a ${paciente.nombre}?'),
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
      try {
        await PacienteService.deletePaciente(paciente.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paciente eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarPacientes();
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
                      'Pacientes',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _nuevoPaciente,
                      icon: Icon(Icons.person_add),
                      label: Text('Nuevo Paciente'),
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
                // Barra de búsqueda
                Container(
                  width: 400,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, teléfono',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.azulCobalto,
                      ),
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
              ],
            ),
          ),

          // Lista de pacientes
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
                          'Error al cargar pacientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(_errorMessage!),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarPacientes,
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _pacientesFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay pacientes',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Agrega un nuevo paciente para comenzar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _pacientesFiltrados.length,
                    itemBuilder: (context, index) {
                      final paciente = _pacientesFiltrados[index];
                      return _buildPacienteCard(paciente);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacienteCard(Paciente paciente) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.azulCobalto,
          child: Text(
            paciente.nombre.isNotEmpty ? paciente.nombre[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          paciente.nombre,
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
                  paciente.telefono,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '${paciente.consultas.length} consultas • ${paciente.ventas.length} compras',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.azulReal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'ver',
              child: ListTile(
                leading: Icon(Icons.visibility, color: AppColors.azulCobalto),
                title: Text('Ver detalles'),
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
            if (value == 'ver') {
              _verDetalle(paciente);
            } else if (value == 'eliminar') {
              _eliminarPaciente(paciente);
            }
          },
        ),
        onTap: () => _verDetalle(paciente),
      ),
    );
  }
}