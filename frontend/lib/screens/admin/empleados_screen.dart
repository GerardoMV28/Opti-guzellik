import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/empleado_service.dart';
import '../../models/empleado.dart';
import '../../widgets/forms/form_card.dart';
import 'empleado_form.dart';

class EmpleadosScreen extends StatefulWidget {
  @override
  _EmpleadosScreenState createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  List<Empleado> _empleados = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  bool _mostrarInactivos = false;

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final empleados = await EmpleadoService.getEmpleados();
      setState(() {
        _empleados = empleados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

List<Empleado> get _empleadosFiltrados {
  var resultados = _empleados;

  if (!_mostrarInactivos) {
    resultados = resultados.where((e) => e.activo).toList();
  }

  if (_searchQuery.isNotEmpty) {
    final query = _searchQuery.toLowerCase().trim();
    resultados = resultados.where((e) {
      final nombreCompleto = e.nombre.toLowerCase();
      final email = e.email.toLowerCase();

      // Buscar en nombre completo O en email
      return nombreCompleto.contains(query) || email.contains(query);
    }).toList();
  }

  return resultados;
}

  void _nuevoEmpleado() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EmpleadoForm()),
    );
    if (result == true) {
      _cargarEmpleados();
    }
  }

  void _editarEmpleado(Empleado empleado) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EmpleadoForm(empleado: empleado)),
    );
    if (result == true) {
      _cargarEmpleados();
    }
  }

  Future<void> _toggleActivo(Empleado empleado) async {
    try {
      await EmpleadoService.toggleActivo(empleado.id, !empleado.activo);
      _cargarEmpleados();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarEmpleado(Empleado empleado) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Empleado permanentemente'),
        content: Text(
          '¿Eliminar a ${empleado.nombre} para siempre? Esta acción no se puede '
          'deshacer. Si solo quieres que no pueda iniciar sesión pero conservar '
          'su historial, usa "Desactivar" en su lugar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar permanentemente'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await EmpleadoService.deleteEmpleado(empleado.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Empleado eliminado permanentemente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarEmpleados();
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
                      'Gestión de Empleados',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulReal,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _nuevoEmpleado,
                      icon: Icon(Icons.add),
                      label: Text('Nuevo Empleado'),
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
                Row(
                  children: [
                    Container(
                      width: 400,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o email...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.azulCobalto,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
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

          // Lista de empleados
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
                          'Error al cargar empleados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(_errorMessage!),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarEmpleados,
                          child: Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _empleadosFiltrados.isEmpty
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
                          'No hay empleados',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _empleadosFiltrados.length,
                    itemBuilder: (context, index) {
                      final empleado = _empleadosFiltrados[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: FormCard(
                        padding: EdgeInsets.zero,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: empleado.activo
                                ? null
                                : Border.all(color: Colors.grey.shade300),
                          ),
                          child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: !empleado.activo
                                ? Colors.grey
                                : empleado.rol == 'admin'
                                    ? AppColors.azulReal
                                    : AppColors.azulCobalto,
                            child: Text(
                              empleado.nombre[0].toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  empleado.nombre,
                                  style: TextStyle(
                                    color: empleado.activo
                                        ? null
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              if (!empleado.activo) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
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
                              Text(empleado.email),
                              Text('Tel: ${empleado.telefono}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: empleado.rol == 'admin'
                                      ? AppColors.azulReal.withOpacity(0.1)
                                      : AppColors.azulCobalto.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  empleado.rol,
                                  style: TextStyle(
                                    color: empleado.rol == 'admin'
                                        ? AppColors.azulReal
                                        : AppColors.azulCobalto,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'editar',
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.edit,
                                        color: AppColors.azulCobalto,
                                      ),
                                      title: Text('Editar'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: ListTile(
                                      leading: Icon(
                                        empleado.activo
                                            ? Icons.block
                                            : Icons.check_circle,
                                        color: empleado.activo
                                            ? Colors.orange
                                            : Colors.green,
                                      ),
                                      title: Text(
                                        empleado.activo
                                            ? 'Desactivar'
                                            : 'Activar',
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'eliminar',
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                      ),
                                      title: Text('Eliminar permanentemente'),
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'editar') {
                                    _editarEmpleado(empleado);
                                  } else if (value == 'toggle') {
                                    _toggleActivo(empleado);
                                  } else if (value == 'eliminar') {
                                    _eliminarEmpleado(empleado);
                                  }
                                },
                              ),
                            ],
                          ),
                          ),
                        ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
