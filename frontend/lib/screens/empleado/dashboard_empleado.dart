// lib/screens/empleado/dashboard_empleado.dart
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'productos/productos_empleado.dart';
import 'ventas/ventas_empleado.dart';
import 'clientes/registro_cliente_empleado.dart';
import 'clientes/lista_clientes_empleado.dart'; // ✅ Agregar esta importación
import '../admin/ventas/ventas_screen.dart';
import '../../services/auth_service.dart';

class EmpleadoDashboard extends StatefulWidget {
  @override
  _EmpleadoDashboardState createState() => _EmpleadoDashboardState();
}

class _EmpleadoDashboardState extends State<EmpleadoDashboard> {
  int _selectedIndex = 0;
  String _nombreEmpleado = 'Empleado';

  final List<String> _titles = [
    'Panel Principal',
    'Punto de Venta',
    'Productos',
    'Clientes',
    'Ventas',
  ];

  @override
  void initState() {
    super.initState();
    _cargarInfoEmpleado();
  }

  Future<void> _cargarInfoEmpleado() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _nombreEmpleado = user['nombre'] ?? 'Empleado';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menú lateral (Sidebar) - VERSIÓN EMPLEADO
          Container(
            width: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.azulReal, AppColors.azulCobalto],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(5, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Logo y nombre de la óptica
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/Guzellik.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Óptica Güzellik',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Empleado',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.turquesa.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _nombreEmpleado,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white30),

                // Menú de navegación
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuItem(0, Icons.dashboard, 'Panel Principal'),
                      _buildMenuItem(1, Icons.shopping_cart, 'Punto de Venta'),
                      _buildMenuItem(2, Icons.inventory, 'Productos'),
                      _buildMenuItem(3, Icons.people, 'Clientes'),
                      _buildMenuItem(4, Icons.receipt, 'Ventas'),
                    ],
                  ),
                ),

                // Botón de cerrar sesión
                Container(
                  padding: EdgeInsets.all(20),
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.white),
                    title: Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      _showLogoutDialog();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Área principal (contenido dinámico)
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // AppBar personalizado
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Icon(Icons.menu, color: AppColors.azulReal),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _titles[_selectedIndex],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.azulReal,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        // Indicador de rol
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.turquesa.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.turquesa),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.badge, size: 16, color: AppColors.turquesa),
                              SizedBox(width: 4),
                              Text(
                                'Usuario Empleado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.turquesa,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Perfil
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.turquesa,
                          child: Text(
                            _nombreEmpleado.isNotEmpty ? _nombreEmpleado[0].toUpperCase() : 'E',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido principal
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: _selectedIndex == index
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(
            icon,
            color: _selectedIndex == index ? Colors.white : Colors.white70,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.white : Colors.white70,
              fontWeight: _selectedIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildPanelPrincipal();
      case 1:
        return VentasScreen();
      case 2:
        return ProductosEmpleado();
      case 3:
        return _buildClientes(); // ✅ Ahora muestra la lista de clientes
      case 4:
        return VentasEmpleado();
      default:
        return _buildPanelPrincipal();
    }
  }

  // ✅ Pantalla de clientes (lista + botón para agregar)
  Widget _buildClientes() {
    return ListaClientesEmpleado();
  }

  // Panel Principal del Empleado
  Widget _buildPanelPrincipal() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mensaje de bienvenida
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.azulReal, AppColors.azulCobalto],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.store,
                      size: 30,
                      color: AppColors.azulReal,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido, $_nombreEmpleado!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Aquí podrás realizar ventas, gestionar productos y registrar clientes.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Accesos rápidos
          Text(
            'Accesos Rápidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.azulReal,
            ),
          ),
          SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildAccesoRapido(
                'Punto de Venta',
                Icons.shopping_cart,
                Colors.green,
                () => setState(() => _selectedIndex = 1),
              ),
              _buildAccesoRapido(
                'Registrar Cliente',
                Icons.person_add,
                Colors.blue,
                () => _registrarCliente(),
              ),
              _buildAccesoRapido(
                'Productos',
                Icons.inventory,
                Colors.orange,
                () => setState(() => _selectedIndex = 2),
              ),
              _buildAccesoRapido(
                'Mis Ventas',
                Icons.receipt,
                Colors.purple,
                () => setState(() => _selectedIndex = 4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Función para registrar nuevo cliente
  void _registrarCliente() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistroClienteEmpleado(),
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cliente registrado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      // Recargar lista de clientes si está visible
      if (_selectedIndex == 3) {
        setState(() {});
      }
    }
  }

  Widget _buildAccesoRapido(String titulo, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(height: 12),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.azulReal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}