import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pacientes/paciente_model.dart';
import '../utils/app_config.dart';

class PacienteService {
  static String get baseUrl => '${AppConfig.apiBaseUrl}/pacientes';
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtener todos los pacientes
  static Future<List<Paciente>> getPacientes() async {
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
        return data.map((json) => Paciente.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar pacientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener paciente por ID
  static Future<Paciente> getPacienteById(String id) async {
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
        return Paciente.fromJson(data);
      } else {
        throw Exception('Error al cargar paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear paciente
  static Future<Paciente> createPaciente(Map<String, dynamic> pacienteData) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(pacienteData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Paciente.fromJson(data);
      } else {
        throw Exception('Error al crear paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar paciente
  static Future<Paciente> updatePaciente(String id, Map<String, dynamic> pacienteData) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(pacienteData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Paciente.fromJson(data);
      } else {
        throw Exception('Error al actualizar paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar paciente (soft delete)
  static Future<void> deletePaciente(String id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Agregar consulta a paciente
  static Future<Paciente> addConsulta(String pacienteId, Map<String, dynamic> consultaData) async {
  try {
    final token = await _getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/$pacienteId/consultas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(consultaData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Paciente.fromJson(data);
    } else {
      throw Exception('Error al agregar consulta: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

  // Buscar pacientes
  static Future<List<Paciente>> buscarPacientes(String query) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/buscar?q=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Paciente.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar pacientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}