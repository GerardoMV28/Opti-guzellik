import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ventas/venta_model.dart';
import '../utils/app_config.dart';

class VentaService {
  static String get baseUrl => '${AppConfig.apiBaseUrl}/ventas';
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

 // Crear venta
static Future<Venta> createVenta(Map<String, dynamic> ventaData) async {
  try {
    final token = await _getToken();
    
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(ventaData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Venta.fromJson(data);
    } else {
      throw Exception('Error al crear venta: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

  // Obtener ventas
  static Future<List<Venta>> getVentas() async {
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
        return data.map((json) => Venta.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar ventas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener venta por ID
static Future<Venta> getVentaById(String id) async {
  try {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Venta.fromJson(data);
    } else {
      throw Exception('Error al cargar venta: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}


// Registrar abono
static Future<Venta> registrarAbono(String ventaId, double monto, String formaPago, String nota) async {
  try {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$ventaId/abono'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'monto': monto,
        'forma_pago': formaPago,
        'nota': nota,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Venta.fromJson(data);
    } else {
      throw Exception('Error al registrar abono: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

  // Actualizar estado de venta
  // Actualizar estado de venta
static Future<Venta> updateEstado(String ventaId, String estado, String nota) async {
  try {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/$ventaId/estado'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'estado': estado, 'nota': nota}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Venta.fromJson(data);
    } else {
      throw Exception('Error al actualizar estado: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}
}