/// URL base de la API. En producción, compilar con:
/// `flutter run --dart-define=API_BASE_URL=https://tu-dominio.com/api`
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );
}
