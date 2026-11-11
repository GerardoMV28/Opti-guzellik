import '../models/chatbot/chat_message.dart';
import '../models/productos/producto_model.dart';
import '../models/pacientes/paciente_model.dart';
import 'producto_service.dart';
import 'paciente_service.dart';
import 'dashboard_service.dart';

class ChatbotService {
  // Caché temporal para no saturar peticiones
  static List<Producto>? _cachedProductos;
  static DateTime? _lastProductosFetch;

  static List<Paciente>? _cachedPacientes;
  static DateTime? _lastPacientesFetch;

  /// Normaliza el texto quitando acentos, signos y convirtiendo a minúsculas
  static String normalize(String text) {
    String res = text.toLowerCase().trim();
    const withAccents = 'áéíóúüñÁÉÍÓÚÜÑ';
    const withoutAccents = 'aeiouunaeiouun';
    for (int i = 0; i < withAccents.length; i++) {
      res = res.replaceAll(withAccents[i], withoutAccents[i]);
    }
    // Quitar caracteres no alfanuméricos excepto espacios
    res = res.replaceAll(RegExp(r'[^\w\s]'), ' ');
    // Reducir espacios múltiples
    res = res.replaceAll(RegExp(r'\s+'), ' ').trim();
    return res;
  }

  /// Procesa el mensaje del usuario y retorna la respuesta del bot
  static Future<ChatMessage> processMessage({
    required String rawText,
    required bool isAdmin,
    String? userName,
  }) async {
    final query = normalize(rawText);
    final String msgId = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. SALUDOS E IDENTIDAD
    if (_matches(query, [
      'hola', 'buen dia', 'buenos dias', 'buenas tardes', 'buenas noches',
      'que tal', 'hey', 'saludos', 'inicio'
    ])) {
      final nombre = userName != null && userName.isNotEmpty ? ' $userName' : '';
      return ChatMessage(
        id: msgId,
        text: '¡Hola$nombre! 👋 Soy el Asistente Virtual de **Óptica Güzellik**.\n\n'
            'Estoy aquí para ayudarte a ubicar cualquier sección, consultar precios, buscar productos en stock o guiarte en el uso de la app.\n\n'
            '¿En qué te puedo orientar hoy?',
        isUser: false,
        timestamp: DateTime.now(),
        quickReplies: [
          '¿Dónde registro un paciente?',
          '¿Dónde registrar una venta?',
          'Buscar precio o stock de producto',
          'Ventas del día de hoy',
          '¿Dónde veo los reportes?',
        ],
      );
    }

    if (_matches(query, ['quien eres', 'que eres', 'como te llamas'])) {
      return ChatMessage(
        id: msgId,
        text: '🤖 Soy el **Asistente Oficial de Óptica Güzellik**.\n\n'
            'Fui diseñado específicamente para este sistema. Conozco todos los menús, '
            'procesos (consultas, ventas, abonos, catálogo) y puedo consultar en tiempo real '
            'el inventario de productos, pacientes y resumen de ventas.',
        isUser: false,
        timestamp: DateTime.now(),
        quickReplies: ['¿Qué puedes hacer?', 'Buscar producto', 'Ir a Pacientes'],
      );
    }

    // 2. AYUDA Y CAPACIDADES
    if (_matches(query, ['ayuda', 'que puedes hacer', 'comandos', 'menu de ayuda', 'opciones'])) {
      return ChatMessage(
        id: msgId,
        text: '💡 **¿En qué te puedo ayudar?**\n\n'
            '📍 **Navegación rápida:**\n'
            '• *"¿Dónde registro un paciente?"*\n'
            '• *"¿Dónde cobro o hago una venta?"*\n'
            '• *"¿Dónde veo los productos o armazones?"*\n'
            '• *"¿Dónde veo los reportes y corte?"*\n'
            '• *"¿Cómo cambiar mi contraseña?"*\n\n'
            '🔍 **Consultas en tiempo real:**\n'
            '• *"Buscar producto [nombre]"* o *"Precio de [armazón]"*\n'
            '• *"Buscar paciente [nombre]"*\n'
            '• *"Ventas de hoy"* o *"Resumen del día"*\n\n'
            '💬 **Otras funciones:**\n'
            '• WhatsApp a pacientes, seguimiento de abonos y entregas.',
        isUser: false,
        timestamp: DateTime.now(),
        quickReplies: [
          '¿Dónde registro un paciente?',
          'Buscar producto',
          'Ventas del día',
        ],
      );
    }

    // 3. FACTURACIÓN Y FACTURAMA
    if (_matches(query, ['factura', 'facturacion', 'facturama', 'cfdi', 'sat', 'timbrar', 'timbre'])) {
      return ChatMessage(
        id: msgId,
        text: '📄 **Facturación y Facturama:**\n\n'
            'La integración con **Facturama (CFDI 4.0 del SAT)** se encuentra actualmente en etapa de análisis para ser incorporada próximamente.\n\n'
            'Por el momento, puedes generar comprobantes de venta, registrar abonos y exportar tus reportes a **Excel o PDF** para tu control contable y fiscal.',
        isUser: false,
        timestamp: DateTime.now(),
        action: isAdmin
            ? ChatbotAction(label: 'Ir a Reportes', targetIndex: 5)
            : ChatbotAction(label: 'Ir a Ventas', targetIndex: 4),
        quickReplies: ['¿Dónde veo los reportes?', '¿Dónde registro una venta?'],
      );
    }

    // 4. CONSULTA EN VIVO: VENTAS DEL DÍA / RESUMEN
    if (_matches(query, [
      'ventas de hoy', 'resumen de hoy', 'cuanto vendimos hoy', 'cuanto se vendio hoy',
      'ventas del dia', 'corte de hoy', 'entregas de hoy', 'proximas entregas'
    ])) {
      try {
        final statsData = await DashboardService.getDashboardStats();
        if (statsData['success'] == true) {
          final data = statsData['data'] ?? {};
          final ventasDelDia = data['ventasDelDia'] as List? ?? [];
          final proximasEntregas = data['proximasEntregas'] as List? ?? [];
          final double totalDia = (data['totalVentasHoy'] ?? 0).toDouble();

          return ChatMessage(
            id: msgId,
            text: '📊 **Resumen del Día de Hoy:**\n\n'
                '• **Ventas registradas hoy:** ${ventasDelDia.length}\n'
                '• **Monto total recaudado:** \$${totalDia.toStringAsFixed(2)}\n'
                '• **Próximas entregas pendientes:** ${proximasEntregas.length}',
            isUser: false,
            timestamp: DateTime.now(),
            statsResult: data,
            action: ChatbotAction(
              label: isAdmin ? 'Ver Panel Principal' : 'Ver Panel Empleado',
              targetIndex: 0,
            ),
            quickReplies: ['¿Dónde registro una venta?', 'Buscar producto'],
          );
        }
      } catch (e) {
        // En caso de que no haya conexión o token
      }
      return ChatMessage(
        id: msgId,
        text: 'Puedes revisar el resumen de ventas y entregas del día directamente en el **Panel Principal**.',
        isUser: false,
        timestamp: DateTime.now(),
        action: ChatbotAction(label: 'Ir al Panel Principal', targetIndex: 0),
      );
    }

    // 5. BÚSQUEDA EN VIVO: PRODUCTOS, ARMAZONES, MICAS, PRECIOS O STOCK
    if (_isProductSearch(query)) {
      final searchTerm = _extractProductSearchTerm(query);
      if (searchTerm.isNotEmpty) {
        final results = await _searchProducts(searchTerm);
        if (results.isNotEmpty) {
          return ChatMessage(
            id: msgId,
            text: '👓 Encontré **${results.length}** producto(s) relacionado(s) con *"$searchTerm"*:',
            isUser: false,
            timestamp: DateTime.now(),
            productResults: results.take(5).toList(),
            action: ChatbotAction(
              label: 'Ver Catálogo Completo',
              targetIndex: 2,
            ),
            quickReplies: ['¿Dónde registro una venta?', '¿Dónde registro un paciente?'],
          );
        } else {
          return ChatMessage(
            id: msgId,
            text: 'No encontré productos que coincidan con *"$searchTerm"*. ¿Deseas revisar el catálogo completo o agregar uno nuevo?',
            isUser: false,
            timestamp: DateTime.now(),
            action: ChatbotAction(
              label: 'Ir a Catálogo de Productos',
              targetIndex: 2,
            ),
            quickReplies: ['Ver todos los productos', '¿Dónde registro un paciente?'],
          );
        }
      }
    }

    // 6. BÚSQUEDA EN VIVO: PACIENTES / CLIENTES
    if (_isPatientSearch(query)) {
      final patientTerm = _extractPatientSearchTerm(query);
      if (patientTerm.isNotEmpty) {
        final patients = await _searchPatients(patientTerm);
        if (patients.isNotEmpty) {
          return ChatMessage(
            id: msgId,
            text: '👤 Encontré **${patients.length}** paciente(s) con *"$patientTerm"*:',
            isUser: false,
            timestamp: DateTime.now(),
            patientResults: patients.take(5).toList(),
            action: ChatbotAction(
              label: isAdmin ? 'Ir a Pacientes' : 'Ir a Clientes',
              targetIndex: 3,
            ),
            quickReplies: ['¿Dónde registro un nuevo paciente?', 'Buscar producto'],
          );
        } else {
          return ChatMessage(
            id: msgId,
            text: 'No encontré pacientes registrados con el nombre o teléfono *"$patientTerm"*.',
            isUser: false,
            timestamp: DateTime.now(),
            action: ChatbotAction(
              label: isAdmin ? 'Ir a Pacientes' : 'Ir a Clientes',
              targetIndex: 3,
            ),
            quickReplies: ['¿Dónde registro un paciente?'],
          );
        }
      }
    }

    // 7. NAVEGACIÓN: PACIENTES / CLIENTES / EXPEDIENTES
    if (_matches(query, [
      'paciente', 'pacientes', 'cliente', 'clientes', 'expediente', 'expedientes',
      'consulta', 'consultas', 'historial clinico', 'agendar cita', 'registrar paciente',
      'nuevo paciente', 'dar de alta paciente'
    ])) {
      final targetIndex = 3;
      return ChatMessage(
        id: msgId,
        text: '👤 **Módulo de ${isAdmin ? "Pacientes" : "Clientes"}:**\n\n'
            'Aquí puedes:\n'
            '1. Dar de alta nuevos pacientes con su historial médico.\n'
            '2. Registrar consultas de adultos o infantes (agudeza visual, síntomas, graduación final).\n'
            '3. Consultar expedientes anteriores y recetas.\n'
            '4. Contactar directamente por WhatsApp para recordatorios.\n\n'
            'Para registrar uno nuevo, presiona el botón verde **"+ Nuevo Paciente"** en la parte superior.',
        isUser: false,
        timestamp: DateTime.now(),
        action: ChatbotAction(
          label: isAdmin ? 'Ir a Pacientes' : 'Ir a Clientes',
          targetIndex: targetIndex,
        ),
        quickReplies: ['Buscar paciente', '¿Dónde registro una venta?'],
      );
    }

    // 8. NAVEGACIÓN: VENTAS / PUNTO DE VENTA / COBRAR / ABONOS
    if (_matches(query, [
      'venta', 'ventas', 'punto de venta', 'pos', 'cobrar', 'caja', 'abono',
      'abonos', 'pagos', 'anticipo', 'liquidar', 'ticket', 'nueva venta', 'hacer venta'
    ])) {
      final targetIndex = isAdmin ? 4 : 1;
      return ChatMessage(
        id: msgId,
        text: '💳 **Punto de Venta y Cobros:**\n\n'
            'Para realizar una venta o cobrar un abono:\n'
            '1. Ve a **${isAdmin ? "Ventas" : "Punto de Venta"}**.\n'
            '2. Selecciona al paciente o regístralo si es nuevo.\n'
            '3. Agrega los productos al carrito (armazones, micas o accesorios).\n'
            '4. Elige el método de pago (Efectivo, Tarjeta, Transferencia).\n'
            '5. Si el paciente deja un anticipo, ingresa el abono y se calculará el saldo restante.\n'
            '6. Finaliza la venta para generar el folio y recibo.',
        isUser: false,
        timestamp: DateTime.now(),
        action: ChatbotAction(
          label: isAdmin ? 'Ir a Ventas' : 'Ir a Punto de Venta',
          targetIndex: targetIndex,
        ),
        quickReplies: ['Ventas del día', '¿Dónde veo el catálogo?'],
      );
    }

    // 9. NAVEGACIÓN: CATÁLOGO DE PRODUCTOS / ARMAZONES / STOCK
    if (_matches(query, [
      'producto', 'productos', 'catalogo', 'armazon', 'armazones', 'micas',
      'lente de contacto', 'lentes de contacto', 'accesorio', 'accesorios',
      'stock', 'inventario', 'agregar producto', 'nuevo producto'
    ])) {
      return ChatMessage(
        id: msgId,
        text: '👓 **Catálogo de Productos e Inventario:**\n\n'
            'En esta sección puedes:\n'
            '• Filtrar por categoría: **Armazones, Micas, Lentes de Contacto y Accesorios**.\n'
            '• Consultar precio de compra, precio al público y stock disponible.\n'
            '• Ver fotos y especificaciones técnicas (material, color, medidas).\n'
            '• ${isAdmin ? "Agregar nuevos productos o actualizar existencias con el botón **\"+ Nuevo Producto\"**." : "Consultar existencias para asesorar al cliente."}',
        isUser: false,
        timestamp: DateTime.now(),
        action: ChatbotAction(
          label: 'Ir a Catálogo de Productos',
          targetIndex: 2,
        ),
        quickReplies: ['Buscar producto por nombre', '¿Dónde registrar una venta?'],
      );
    }

    // 10. NAVEGACIÓN: REPORTES Y GRÁFICAS (ADMIN)
    if (_matches(query, [
      'reporte', 'reportes', 'grafica', 'graficas', 'estadistica', 'estadisticas',
      'ganancias', 'corte de caja', 'ingresos', 'excel', 'pdf', 'descargar reporte'
    ])) {
      if (!isAdmin) {
        return ChatMessage(
          id: msgId,
          text: '🔒 El módulo de **Reportes y Estadísticas Financieras** está disponible exclusivamente para usuarios con rol de **Administrador**.',
          isUser: false,
          timestamp: DateTime.now(),
          quickReplies: ['Ir a Punto de Venta', 'Buscar producto'],
        );
      }

      return ChatMessage(
        id: msgId,
        text: '📊 **Reportes y Estadísticas:**\n\n'
            'En el menú de **Reportes** puedes:\n'
            '• Ver gráficas de ventas semanales, mensuales o por rango de fechas.\n'
            '• Identificar los productos más vendidos.\n'
            '• Consultar ingresos totales y métodos de pago más usados.\n'
            '• **Exportar reportes a Excel o PDF** con un solo clic.',
        isUser: false,
        timestamp: DateTime.now(),
        action: ChatbotAction(
          label: 'Ir a Reportes',
          targetIndex: 5,
        ),
        quickReplies: ['Ventas del día', 'Ir a Catálogo'],
      );
    }

    // 11. NAVEGACIÓN: GESTIÓN DE EMPLEADOS (ADMIN)
    if (_matches(query, [
      'empleado', 'empleados', 'usuario', 'usuarios', 'personal', 'roles',
      'crear empleado', 'nuevo empleado', 'dar de alta empleado'
    ])) {
      if (!isAdmin) {
        return ChatMessage(
          id: msgId,
          text: '🔒 La gestión de empleados y usuarios es una función restringida a Administradores.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      }

      return ChatMessage(
        id: msgId,
        text: '👥 **Gestión de Empleados:**\n\n'
            'En esta sección puedes:\n'
            '• Dar de alta nuevos empleados con usuario y contraseña.\n'
            '• Asignar roles (Admin o Empleado).\n'
            '• Modificar información o desactivar cuentas.',
        isUser: false,
        timestamp: DateTime.now(),
        action: ChatbotAction(
          label: 'Ir a Empleados',
          targetIndex: 1,
        ),
        quickReplies: ['Ir al Panel Principal', '¿Dónde veo los reportes?'],
      );
    }

    // 12. NAVEGACIÓN: CONFIGURACIÓN Y PERFIL
    if (_matches(query, [
      'configuracion', 'ajustes', 'contrasena', 'password', 'cambiar clave',
      'datos de la optica', 'perfil'
    ])) {
      if (isAdmin) {
        return ChatMessage(
          id: msgId,
          text: '⚙️ **Configuración del Sistema:**\n\n'
              'Ve al menú lateral izquierdo y haz clic en **Configuración** para actualizar información de la óptica, datos generales o cambiar tu contraseña.',
          isUser: false,
          timestamp: DateTime.now(),
          action: ChatbotAction(label: 'Ir a Configuración', targetIndex: 6),
          quickReplies: ['Ir al Panel Principal'],
        );
      } else {
        return ChatMessage(
          id: msgId,
          text: '⚙️ Para cambios en tu cuenta o restablecer tu contraseña, solicítalo con el Administrador de la óptica.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    }

    // 13. WHATSAPP Y COMUNICACIÓN CON CLIENTES
    if (_matches(query, ['whatsapp', 'mensaje al cliente', 'notificar', 'recordatorio'])) {
      return ChatMessage(
        id: msgId,
        text: '📱 **Integración con WhatsApp:**\n\n'
            'Puedes enviar mensajes directos a tus pacientes sin guardarlos en tu agenda:\n'
            '1. Ve al detalle de cualquier **Paciente** o **Venta**.\n'
            '2. Presiona el botón verde de **WhatsApp**.\n'
            '3. Se abrirá la conversación con un mensaje sugerido listo para confirmar entregas o citas.',
        isUser: false,
        timestamp: DateTime.now(),
        action: ChatbotAction(
          label: isAdmin ? 'Ir a Pacientes' : 'Ir a Clientes',
          targetIndex: 3,
        ),
        quickReplies: ['¿Dónde registrar una venta?', 'Ventas de hoy'],
      );
    }

    // 14. DEFAULT / NO ENTENDIDO
    return ChatMessage(
      id: msgId,
      text: '🤔 No encontré una respuesta exacta para: *"$rawText"*.\n\n'
          'Puedes preguntarme cosas como:\n'
          '• *"¿Dónde registro un nuevo paciente?"*\n'
          '• *"¿Dónde cobro o hago una venta?"*\n'
          '• *"Buscar producto [nombre o armazón]"*\n'
          '• *"Buscar paciente [nombre]"*\n'
          '• *"Ventas de hoy"*\n\n'
          'O selecciona uno de los accesos rápidos:',
      isUser: false,
      timestamp: DateTime.now(),
      quickReplies: [
        '¿Dónde registro un paciente?',
        '¿Dónde registrar una venta?',
        'Buscar producto',
        'Ventas del día',
      ],
    );
  }

  // --- MÉTODOS AUXILIARES ---

  static bool _matches(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(normalize(kw))) return true;
    }
    return false;
  }

  static bool _isProductSearch(String text) {
    final lower = text.toLowerCase();
    if (lower.startsWith('buscar producto') ||
        lower.startsWith('precio de') ||
        lower.startsWith('stock de') ||
        lower.startsWith('cuanto cuesta') ||
        lower.startsWith('tienes') ||
        lower.startsWith('hay stock de') ||
        lower.contains('armazon') ||
        lower.contains('micas') ||
        lower.contains('lentes de contacto')) {
      return true;
    }
    return false;
  }

  static String _extractProductSearchTerm(String text) {
    String t = text;
    final prefixes = [
      'buscar producto', 'buscar armazon', 'buscar lentes', 'buscar',
      'precio de', 'precio del', 'precio de la', 'precio',
      'stock de', 'stock del', 'stock',
      'cuanto cuesta el', 'cuanto cuesta la', 'cuanto cuesta',
      'tienes', 'hay stock de', 'hay', 'donde estan los'
    ];
    for (final p in prefixes) {
      if (t.startsWith(p)) {
        t = t.substring(p.length).trim();
        break;
      }
    }
    return t.trim();
  }

  static bool _isPatientSearch(String text) {
    final lower = text.toLowerCase();
    if (lower.startsWith('buscar paciente') ||
        lower.startsWith('buscar cliente') ||
        lower.startsWith('paciente') ||
        lower.startsWith('cliente') ||
        lower.startsWith('telefono de') ||
        lower.startsWith('expediente de')) {
      return true;
    }
    return false;
  }

  static String _extractPatientSearchTerm(String text) {
    String t = text;
    final prefixes = [
      'buscar paciente', 'buscar cliente', 'telefono de', 'expediente de',
      'paciente', 'cliente', 'buscar'
    ];
    for (final p in prefixes) {
      if (t.startsWith(p)) {
        t = t.substring(p.length).trim();
        break;
      }
    }
    return t.trim();
  }

  static Future<List<Producto>> _searchProducts(String term) async {
    try {
      final now = DateTime.now();
      if (_cachedProductos == null ||
          _lastProductosFetch == null ||
          now.difference(_lastProductosFetch!).inMinutes > 5) {
        _cachedProductos = await ProductoService.getProductos();
        _lastProductosFetch = now;
      }

      final normalizedTerm = normalize(term);
      return _cachedProductos!.where((p) {
        final name = normalize(p.nombre);
        final marca = normalize(p.marca);
        final modelo = normalize(p.modelo);
        final codigo = normalize(p.codigo);
        final desc = normalize(p.descripcion);
        return name.contains(normalizedTerm) ||
            marca.contains(normalizedTerm) ||
            modelo.contains(normalizedTerm) ||
            codigo.contains(normalizedTerm) ||
            desc.contains(normalizedTerm);
      }).toList();
    } catch (e) {
      print('Error al buscar productos para chatbot: $e');
      return [];
    }
  }

  static Future<List<Paciente>> _searchPatients(String term) async {
    try {
      final now = DateTime.now();
      if (_cachedPacientes == null ||
          _lastPacientesFetch == null ||
          now.difference(_lastPacientesFetch!).inMinutes > 5) {
        _cachedPacientes = await PacienteService.getPacientes();
        _lastPacientesFetch = now;
      }

      final normalizedTerm = normalize(term);
      return _cachedPacientes!.where((p) {
        final name = normalize(p.nombre);
        final tel = normalize(p.telefono);
        return name.contains(normalizedTerm) || tel.contains(normalizedTerm);
      }).toList();
    } catch (e) {
      print('Error al buscar pacientes para chatbot: $e');
      return [];
    }
  }
}
