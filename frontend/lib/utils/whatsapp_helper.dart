import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  /// Limpia el teléfono guardado y le antepone el código de país (52,
  /// México) si hace falta, para que el enlace de WhatsApp lo reconozca.
  static String? _formatearTelefono(String telefono) {
    final digitos = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty) return null;
    if (digitos.startsWith('52')) return digitos;
    if (digitos.length == 10) return '52$digitos';
    return digitos;
  }

  /// Abre WhatsApp con el número del paciente/cliente y un mensaje
  /// predeterminado ya escrito, listo para revisar y enviar.
  static Future<void> contactar(
    BuildContext context, {
    required String telefono,
    required String nombre,
  }) async {
    final numero = _formatearTelefono(telefono);
    if (numero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Este paciente no tiene un teléfono válido registrado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final primerNombre = nombre.trim().split(' ').first;
    final mensaje = 'Hola $primerNombre, te saluda Óptica Güzellik. '
        '¿En qué podemos ayudarte?';

    final uri = Uri.parse(
      'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}',
    );

    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}