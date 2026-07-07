import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/productos/producto_model.dart';
import '../utils/app_config.dart';

class ProductoService {
  static String get baseUrl => '${AppConfig.apiBaseUrl}/productos';
  
  // Obtener token de autenticación
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtener todos los productos
  static Future<List<Producto>> getProductos() async {
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
        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener productos por tipo
  static Future<List<Producto>> getProductosPorTipo(String tipo) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl?tipo=$tipo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener producto por ID
  static Future<Producto> getProductoById(String id) async {
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
        return Producto.fromJson(data);
      } else {
        throw Exception('Error al cargar producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear producto
  static Future<Producto> createProducto(Map<String, dynamic> productoData) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productoData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Producto.fromJson(data);
      } else {
        throw Exception('Error al crear producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar producto
  static Future<Producto> updateProducto(String id, Map<String, dynamic> productoData) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productoData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Producto.fromJson(data);
      } else {
        throw Exception('Error al actualizar producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar producto (soft delete)
  static Future<void> deleteProducto(String id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar stock
  static Future<Producto> updateStock(String id, int nuevoStock) async {
    try {
      final token = await _getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/stock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'stock': nuevoStock}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Producto.fromJson(data);
      } else {
        throw Exception('Error al actualizar stock: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}