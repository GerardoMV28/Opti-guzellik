import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Guarda el Excel en un archivo temporal y abre el diálogo de compartir.
/// Usado en Android, iOS, Windows, macOS y Linux.
Future<void> guardarYCompartirExcel(
  List<int> bytes,
  String filename,
  String shareText,
) async {
  final directory = await getTemporaryDirectory();
  final path = '${directory.path}/$filename';
  final file = File(path);
  await file.writeAsBytes(bytes);
  await Share.shareXFiles([XFile(path)], text: shareText);
}
