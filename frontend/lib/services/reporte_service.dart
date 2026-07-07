import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reportes/resumen_ventas_model.dart';
import '../models/reportes/venta_reporte_model.dart';
import '../models/reportes/producto_top_model.dart';
import '../utils/app_config.dart';
import '../utils/auth_storage.dart';

class ReporteService {
  static String get baseUrl => '${AppConfig.apiBaseUrl}/reportes';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Inicia sesión de nuevo.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtener resumen de ventas por período
  static Future<ResumenVentas> getResumenVentas({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/resumen?inicio=${fechaInicio.toIso8601String()}&fin=${fechaFin.toIso8601String()}'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        await AuthStorage.clearSession();
        throw Exception('Sesión expirada. Inicia sesión de nuevo.');
      }
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ResumenVentas.fromJson(data);
      } else {
        throw Exception('Error al cargar resumen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener ventas del día
  static Future<List<VentaReporte>> getVentasDelDia() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ventas/dia'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        await AuthStorage.clearSession();
        throw Exception('Sesión expirada. Inicia sesión de nuevo.');
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VentaReporte.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar ventas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener productos más vendidos
  static Future<List<ProductoTop>> getProductosMasVendidos({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    int limite = 10,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/productos/top?inicio=${fechaInicio.toIso8601String()}&fin=${fechaFin.toIso8601String()}&limite=$limite'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        await AuthStorage.clearSession();
        throw Exception('Sesión expirada. Inicia sesión de nuevo.');
      }
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductoTop.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener productos con stock bajo
  static Future<List<dynamic>> getProductosBajoStock() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/productos/bajo-stock'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        await AuthStorage.clearSession();
        throw Exception('Sesión expirada. Inicia sesión de nuevo.');
      }
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar stock bajo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener ventas por empleado
  static Future<Map<String, dynamic>> getVentasPorEmpleado({
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ventas/por-empleado?inicio=${fechaInicio.toIso8601String()}&fin=${fechaFin.toIso8601String()}'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        await AuthStorage.clearSession();
        throw Exception('Sesión expirada. Inicia sesión de nuevo.');
      }
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar ventas por empleado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}