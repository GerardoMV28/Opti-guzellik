/// Validaciones de entrada reutilizables (formato, longitud, sin confiar en el cliente).
class InputValidators {
  InputValidators._();

  static final RegExp _email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo';
    }
    final t = value.trim();
    if (t.length > 254) {
      return 'Correo demasiado largo';
    }
    if (!_email.hasMatch(t)) {
      return 'Formato de correo no válido';
    }
    return null;
  }

  /// Contraseña en login: solo límites razonables; la política fuerte aplica en registro (backend).
  static String? passwordLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (value.length > 128) {
      return 'Contraseña demasiado larga';
    }
    return null;
  }

  static String trimSingleLine(String input, int maxLength) {
    var s = input.replaceAll(RegExp(r'[\r\n]'), ' ').trim();
    if (s.length > maxLength) {
      s = s.substring(0, maxLength);
    }
    return s;
  }
}
