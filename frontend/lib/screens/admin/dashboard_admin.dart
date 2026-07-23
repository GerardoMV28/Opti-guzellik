import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/dashboard_service.dart';
import '../../../utils/auth_storage.dart';
import 'empleados_screen.dart';
import 'productos/productos_screen.dart';
import 'reportes/reportes_screen.dart';
import 'pacientes/pacientes_screen.dart';
import 'ventas/ventas_screen.dart';
import '../../../utils/venta_estados.dart';
import 'configuracion_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // Variables para datos dinámicos
  Map<String, dynamic> _dashboardData = {};
  List<dynamic> _ventasDelDia = [];
  List<dynamic> _proximasEntregas = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Lista de títulos para el AppBar
  final List<String> _titles = [
    'Panel Principal',
    'Gestión de Empleados',
    'Catálogo de Productos',
    'Pacientes',
    'Ventas',
    'Reportes',
    'Configuración',
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosDashboard();
  }

  Future<void> _cargarDatosDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await DashboardService.getDashboardStats();
      
      if (response['success'] == true) {
        final data = response['data'];
        setState(() {
          _dashboardData = data;
          _ventasDelDia = data['ventasDelDia'] ?? [];
          _proximasEntregas = data['proximasEntregas'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception(response['error'] ?? 'Error al cargar datos');
      }
    } catch (e) {
      print('Error al cargar dashboard: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menú lateral (Sidebar)
          Container(
            width: 280,
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
                        width: 80,
                        height: 80,
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
                      SizedBox(height: 16),
                      Text(
                        'Óptica Güzellik',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Administrador',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
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
                      _buildMenuItem(1, Icons.people, 'Empleados'),
                      _buildMenuItem(2, Icons.inventory, 'Productos'),
                      _buildMenuItem(3, Icons.person, 'Pacientes'),
                      _buildMenuItem(4, Icons.receipt, 'Ventas'),
                      _buildMenuItem(5, Icons.pie_chart, 'Reportes'),
                      _buildMenuItem(6, Icons.settings, 'Configuración'),
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
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: Colors.white,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Con la pantalla angosta se oculta el buscador para
                        // que el título y los íconos de la derecha nunca se
                        // encimen ni desborden (RenderFlex overflow).
                        final mostrarBuscador = constraints.maxWidth > 640;

                        return Row(
                          children: [
                            Icon(Icons.menu, color: AppColors.azulReal),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _titles[_selectedIndex],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.azulReal,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (mostrarBuscador) ...[
                              SizedBox(width: 16),
                              // Barra de búsqueda
                              SizedBox(
                                width: 300,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Buscar...',
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
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(width: 16),
                            // Notificaciones
                            Stack(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.azulReal,
                                  ),
                                  onPressed: () {},
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 8),
                            // Botón de recargar datos
                            IconButton(
                              icon: Icon(Icons.refresh, color: AppColors.azulReal),
                              onPressed: _cargarDatosDashboard,
                            ),
                            SizedBox(width: 8),
                            // Perfil
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.turquesa,
                              child: Text(
                                'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
          ),
          title: Text(
            title,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.white : Colors.white70,
              fontWeight: _selectedIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
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
        return EmpleadosScreen();
      case 2:
        return ProductosScreen();
      case 3:
        return PacientesScreen();
      case 4:
        return VentasScreen();
      case 5:
        return ReportesScreen();
      case 6:
        return _buildConfiguracion();
      default:
        return _buildPanelPrincipal();
    }
  }

  // Panel Principal (Dashboard)
  Widget _buildPanelPrincipal() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.azulReal,
            ),
            SizedBox(height: 16),
            Text(
              'Cargando datos del dashboard...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error al cargar los datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(_errorMessage),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarDatosDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulReal,
              ),
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjetas de estadísticas
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _buildStatCard(
                'Ventas Hoy',
                '\$${(_dashboardData['ventasHoy'] ?? 0).toStringAsFixed(2)}',
                Icons.today,
                Colors.green,
                '${_dashboardData['totalVentasHoyCount'] ?? 0} ventas',
              ),
              _buildStatCard(
                'Clientes',
                '${_dashboardData['clientesHoy'] ?? 0}',
                Icons.people,
                Colors.blue,
                'atendidos hoy',
              ),
              _buildStatCard(
                'Productos',
                '${_dashboardData['totalProductos'] ?? 0}',
                Icons.inventory,
                Colors.orange,
                '${_dashboardData['productosBajosStock'] ?? 0} bajo stock',
              ),
              _buildStatCard(
                'Ingresos Mes',
                '\$${(_dashboardData['ingresosMes'] ?? 0).toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.purple,
                'total del mes',
              ),
            ],
          ),

          SizedBox(height: 32),

          // Desglose de pagos
          Container(
            margin: EdgeInsets.only(bottom: 24),
            padding: EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desglose de Ventas Hoy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildPagoCard(
                      'Efectivo',
                      '\$${(_dashboardData['efectivoHoy'] ?? 0).toStringAsFixed(2)}',
                      Icons.money,
                      Colors.green,
                    ),
                    SizedBox(width: 16),
                    _buildPagoCard(
                      'Tarjeta',
                      '\$${(_dashboardData['tarjetaHoy'] ?? 0).toStringAsFixed(2)}',
                      Icons.credit_card,
                      Colors.blue,
                    ),
                    SizedBox(width: 16),
                    _buildPagoCard(
                      'Transferencia',
                      '\$${(_dashboardData['transferenciaHoy'] ?? 0).toStringAsFixed(2)}',
                      Icons.account_balance,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Gráficas y tablas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ventas del día
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ventas del Día',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                      SizedBox(height: 20),
                      _ventasDelDia.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(Icons.receipt, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      'No hay ventas registradas hoy',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildVentasListaFromDB(),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 24),

              // Próximas entregas
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Próximas Entregas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulReal,
                        ),
                      ),
                      SizedBox(height: 20),
                      _proximasEntregas.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(Icons.local_shipping, size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      'No hay entregas pendientes',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildEntregasListaFromDB(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagoCard(String titulo, String monto, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              monto,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de estadística
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
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
                child: Icon(icon, color: color),
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: color),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.azulReal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // Función para construir lista de ventas desde DB
  Widget _buildVentasListaFromDB() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _ventasDelDia.length,
      itemBuilder: (context, index) {
        final venta = _ventasDelDia[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.azulCobalto.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        venta['hora'] ?? '--:--',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulCobalto,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venta['cliente'] ?? 'Cliente',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Total: \$${(venta['total'] ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Pago: ${_getFormaPagoTexto(venta['formaPago'])}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: VentaEstados.color(venta['estado'] as String?).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  VentaEstados.etiqueta(venta['estado'] as String?),
                  style: TextStyle(
                    color: VentaEstados.color(venta['estado'] as String?),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Función para construir lista de entregas desde DB
  Widget _buildEntregasListaFromDB() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _proximasEntregas.length,
      itemBuilder: (context, index) {
        final entrega = _proximasEntregas[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
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
                  color: AppColors.turquesa.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.turquesa,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entrega['cliente'] ?? 'Cliente',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${entrega['tipo'] ?? 'Producto'} - ${entrega['hora'] ?? 'Hora no definida'}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getFormaPagoTexto(String? formaPago) {
    switch (formaPago) {
      case 'efectivo':
        return '💵 Efectivo';
      case 'tarjeta':
        return '💳 Tarjeta';
      case 'transferencia':
        return '🏦 Transferencia';
      case 'mixto':
        return '🔄 Mixto';
      default:
        return formaPago ?? 'No especificado';
    }
  }

  Widget _buildConfiguracion() {
    return ConfiguracionScreen();
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
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
              // Usar el AuthStorage correctamente
              await AuthStorage.clearSession();
              if (mounted) {
                Navigator.pop(context); // Cerrar diálogo
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