// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';
import '../utils/auth_storage.dart';

class AuthService {
  static String get _baseUrl => AppConfig.apiBaseUrl;

  static String _messageFromBody(int statusCode, Map<String, dynamic>? data) {
    if (statusCode == 429) {
      return 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';
    }
    if (statusCode >= 500) {
      return 'Error en el servidor. Inténtalo más tarde.';
    }
    if (data == null) {
      return 'No se pudo iniciar sesión';
    }
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map && first['msg'] != null) {
        final msg = first['msg'].toString();
        if (msg.length <= 300) return msg;
      }
    }
    final msg = data['message'];
    if (msg is String && msg.trim().isNotEmpty) {
      if (msg.length > 200) return 'No se pudo iniciar sesión';
      return msg.trim();
    }
    return 'Credenciales incorrectas';
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } on FormatException {
        return {
          'success': false,
          'message': 'Respuesta del servidor no válida',
        };
      }

      if (response.statusCode == 200 && data != null) {
        final token = data['token'];
        if (token is String && token.isNotEmpty) {
          await AuthStorage.saveToken(token);
        }

        final userData = data['user'];
        if (userData is Map<String, dynamic>) {
          await AuthStorage.saveUserData(userData);
        }

        return {
          'success': true,
          'user': userData,
        };
      }

      return {
        'success': false,
        'message': _messageFromBody(response.statusCode, data),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión con el servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> checkSession() async {
    final token = await AuthStorage.getToken();
        
    if (token == null || token.isEmpty) {
      return {'loggedIn': false};
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        Map<String, dynamic>? data;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        } on FormatException {
          await AuthStorage.clearSession();
          return {'loggedIn': false};
        }

        final userData = data?['user'];
        if (userData is Map<String, dynamic>) {
          await AuthStorage.saveUserData(userData);
          return {
            'loggedIn': true,
            'user': userData,
          };
        }

        return {'loggedIn': false};
      } else {
        await AuthStorage.clearSession();
        return {'loggedIn': false};
      }
    } catch (e) {

      return {'loggedIn': false};
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userData = await AuthStorage.getUserData();
      if (userData != null) {

        return userData;
      }
      return null;
    } catch (e) {

      return null;
    }
  }

  static Future<void> logout() async {
    await AuthStorage.clearSession();
  }

  static Future<Map<String, dynamic>> changePassword(
    String passwordActual,
    String passwordNueva,
  ) async {
    final token = await AuthStorage.getToken();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/auth/cambiar-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'passwordActual': passwordActual,
          'passwordNueva': passwordNueva,
        }),
      );

      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } on FormatException {
        return {'success': false, 'message': 'Respuesta del servidor no válida'};
      }

      if (response.statusCode == 200) {
        return {'success': true};
      }

      return {
        'success': false,
        'message': _messageFromBody(response.statusCode, data),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión con el servidor'};
    }
  }
}