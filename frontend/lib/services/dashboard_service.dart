// lib/services/dashboard_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';
import '../utils/auth_storage.dart';

class DashboardService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Obtener estadísticas del dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final token = await AuthStorage.getToken();
      
      if (token == null) {
        throw Exception('No hay sesión activa. Por favor inicie sesión.');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Asegúrate que sea "Bearer" con espacio
        },
      ); 

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        // Token expirado o inválido
        await AuthStorage.clearSession();
        throw Exception('Sesión expirada. Por favor inicie sesión nuevamente.');
      } else {
        throw Exception('Error al cargar estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en DashboardService.getDashboardStats: $e');
      throw Exception('Error de conexión con el servidor');
    }
  }

  // Obtener ventas del día
  static Future<List<dynamic>> getVentasDia() async {
    try {
      final token = await AuthStorage.getToken();
      
      if (token == null) return [];
      
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/ventas/dia'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error en DashboardService.getVentasDia: $e');
      return [];
    }
  }

  // Obtener productos con stock bajo
  static Future<List<dynamic>> getProductosStockBajo() async {
    try {
      final token = await AuthStorage.getToken();
      
      if (token == null) return [];
      
      final response = await http.get(
        Uri.parse('$baseUrl/productos/stock-bajo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print('Error en DashboardService.getProductosStockBajo: $e');
      return [];
    }
  }
}