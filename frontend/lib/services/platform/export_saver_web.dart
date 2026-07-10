import 'dart:html' as html;

/// Dispara la descarga del Excel en el navegador. Usado solo en Flutter Web.
Future<void> guardarYCompartirExcel(
  List<int> bytes,
  String filename,
  String shareText,
) async {
  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
