/// Implementación por defecto, usada solo si la plataforma no es ni IO ni web.
Future<void> guardarYCompartirExcel(
  List<int> bytes,
  String filename,
  String shareText,
) async {
  throw UnsupportedError('Exportación a Excel no soportada en esta plataforma.');
}
