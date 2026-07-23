import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/empleado.dart';
import '../utils/app_config.dart';

class EmpleadoService {
  static String get baseUrl => '${AppConfig.apiBaseUrl}/usuarios';

  // Obtener token de autenticación
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Extrae el mensaje de error enviado por el backend, si existe
  static String _mensajeError(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map && data['message'] is String) {
        return data['message'];
      }
    } catch (_) {}
    return 'Error ${response.statusCode}';
  }

  // Obtener todos los empleados
  static Future<List<Empleado>> getEmpleados() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Empleado.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar empleados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear empleado
  static Future<Empleado> createEmpleado(Map<String, dynamic> empleadoData) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(empleadoData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Empleado.fromJson(data);
      } else {
        throw Exception(_mensajeError(response));
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar empleado
  static Future<Empleado> updateEmpleado(String id, Map<String, dynamic> empleadoData) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(empleadoData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Empleado.fromJson(data);
      } else {
        throw Exception(_mensajeError(response));
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar empleado (desactivar)
  static Future<void> deleteEmpleado(String id) async {
    final token = await _getToken();
    http.Response response;
    try {
      response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }

    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }

  // Activar/Desactivar empleado
  static Future<Empleado> toggleActivo(String id, bool activo) async {
    final token = await _getToken();
    http.Response response;
    try {
      response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'activo': activo}),
      );
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Empleado.fromJson(data);
    } else {
      throw Exception(_mensajeError(response));
    }
  }
}