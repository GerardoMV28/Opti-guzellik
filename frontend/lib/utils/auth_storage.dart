import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'token';
  static const String _userDataKey = 'user_data';
  static const String _recentEmailsKey = 'recent_emails';
  static const int _maxRecentEmails = 5;

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token;
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userDataKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<List<String>> getRecentEmails() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentEmailsKey) ?? [];
  }

  static Future<void> addRecentEmail(String email) async {
    final correo = email.trim().toLowerCase();
    if (correo.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final actuales = prefs.getStringList(_recentEmailsKey) ?? [];

    actuales.removeWhere((e) => e.toLowerCase() == correo);
    actuales.insert(0, correo);

    await prefs.setStringList(
      _recentEmailsKey,
      actuales.take(_maxRecentEmails).toList(),
    );
  }
}