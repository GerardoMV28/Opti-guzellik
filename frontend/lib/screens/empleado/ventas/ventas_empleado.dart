// lib/screens/empleado/ventas/ventas_empleado.dart
import 'package:flutter/material.dart';
import '../../../utils/colors.dart';
import '../../../services/venta_service.dart';
import '../../../models/ventas/venta_model.dart';
import '../../../utils/venta_estados.dart';

class VentasEmpleado extends StatefulWidget {
  @override
  _VentasEmpleadoState createState() => _VentasEmpleadoState();
}

class _VentasEmpleadoState extends State<VentasEmpleado> {
  List<Venta> _ventas = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ventas = await VentaService.getVentas();
      setState(() {
        _ventas = ventas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
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
          'Historial de Ventas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.azulReal,
          ),
        ),
        // ✅ Botón "Nueva Venta" ELIMINADO
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.azulReal),
            )
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
                        onPressed: _cargarVentas,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _ventas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay ventas registradas'),
                          SizedBox(height: 8),
                          Text(
                            'Ve a "Punto de Venta" para crear tu primera venta',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _ventas.length,
                      itemBuilder: (context, index) {
                        final venta = _ventas[index];
                        return _buildVentaCard(venta);
                      },
                    ),
    );
  }

  Widget _buildVentaCard(Venta venta) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Venta #${venta.id?.substring(venta.id!.length - 6) ?? '---'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: VentaEstados.color(venta.estado).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    VentaEstados.etiqueta(venta.estado),
                    style: TextStyle(
                      fontSize: 11,
                      color: VentaEstados.color(venta.estado),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Fecha: ${_formatDate(venta.fecha)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Cliente: ${venta.pacienteNombre ?? 'Cliente general'}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${venta.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.turquesa,
                  ),
                ),
                Text(
                  '${venta.productos.length} producto(s)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}