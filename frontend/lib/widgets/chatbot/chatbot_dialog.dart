import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/chatbot/chat_message.dart';
import '../../models/productos/producto_model.dart';
import '../../models/pacientes/paciente_model.dart';
import '../../services/chatbot_service.dart';
import '../../utils/whatsapp_helper.dart';

class ChatbotDialog extends StatefulWidget {
  final bool isAdmin;
  final String? userName;
  final Function(int targetIndex)? onNavigate;

  const ChatbotDialog({
    Key? key,
    required this.isAdmin,
    this.userName,
    this.onNavigate,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required bool isAdmin,
    String? userName,
    Function(int targetIndex)? onNavigate,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar Asistente',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) {
        return ChatbotDialog(
          isAdmin: isAdmin,
          userName: userName,
          onNavigate: onNavigate,
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value) - 1.0;
        return Transform.translate(
          offset: Offset(0, curvedValue * -20),
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  @override
  _ChatbotDialogState createState() => _ChatbotDialogState();
}

class _ChatbotDialogState extends State<ChatbotDialog> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _enviarMensajeBienvenida();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _enviarMensajeBienvenida() {
    final nombre = widget.userName != null && widget.userName!.isNotEmpty
        ? ' ${widget.userName}'
        : '';
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'welcome',
          text: '¡Hola$nombre! 👋 Soy tu **Asistente de Óptica Güzellik**.\n\n'
              '¿Necesitas saber en dónde se encuentra algo o hacer alguna consulta? '
              'Puedes escribir tu pregunta o tocar una de las sugerencias:',
          isUser: false,
          timestamp: DateTime.now(),
          quickReplies: [
            '¿Dónde registro un paciente?',
            widget.isAdmin ? '¿Dónde registrar una venta?' : '¿Dónde hacer una venta?',
            'Buscar precio o stock de producto',
            'Ventas del día de hoy',
            if (widget.isAdmin) '¿Dónde veo los reportes?',
            '¿Qué puedes hacer?',
          ],
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: trimmed,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    // Procesar con el servicio del Chatbot
    try {
      final response = await ChatbotService.processMessage(
        rawText: trimmed,
        isAdmin: widget.isAdmin,
        userName: widget.userName,
      );

      if (mounted) {
        setState(() {
          _messages.add(response);
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: 'Ocurrió un error al procesar tu consulta. Intenta de nuevo.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _reiniciarChat() {
    setState(() {
      _messages.clear();
      _enviarMensajeBienvenida();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final isDesktop = media.width > 700;

    // Dimensiones óptimas flotantes tipo widget de ayuda
    final dialogWidth = isDesktop ? 480.0 : media.width * 0.95;
    final dialogHeight = isDesktop ? 640.0 : media.height * 0.88;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMessagesList()),
              if (_isTyping) _buildTypingIndicator(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.azulReal, AppColors.azulCobalto],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Guzellik.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.smart_toy,
                      color: AppColors.azulReal,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent[400],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Asistente Güzellik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isAdmin ? 'En línea • Modo Admin' : 'En línea • Asistente',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Reiniciar conversación',
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70, size: 22),
              onPressed: _reiniciarChat,
            ),
          ),
          Tooltip(
            message: 'Cerrar',
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          return _buildMessageItem(msg);
        },
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.azulReal, AppColors.azulCobalto],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.azulReal.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.turquesa,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.azulReal.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.turquesa.withOpacity(0.4)),
              ),
              child: Icon(Icons.smart_toy, color: AppColors.azulReal, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildRichText(msg.text),
                  ),
                  if (msg.action != null) ...[
                    const SizedBox(height: 10),
                    _buildActionButton(msg.action!),
                  ],
                  if (msg.productResults != null && msg.productResults!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildProductCards(msg.productResults!),
                  ],
                  if (msg.patientResults != null && msg.patientResults!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildPatientCards(msg.patientResults!),
                  ],
                  if (msg.statsResult != null) ...[
                    const SizedBox(height: 10),
                    _buildStatsBadge(msg.statsResult!),
                  ],
                  if (msg.quickReplies != null && msg.quickReplies!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildQuickReplies(msg.quickReplies!),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildRichText(String text) {
    // Formateador simple de negritas con markdown **palabra** y saltos de línea
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final Match match in exp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: Colors.grey.shade800, fontSize: 13.5, height: 1.4),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: AppColors.azulReal,
          fontWeight: FontWeight.bold,
          fontSize: 13.5,
          height: 1.4,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: Colors.grey.shade800, fontSize: 13.5, height: 1.4),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildActionButton(ChatbotAction action) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.turquesa,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
      label: Text(
        action.label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      onPressed: () {
        if (action.targetIndex != null && widget.onNavigate != null) {
          widget.onNavigate!(action.targetIndex!);
          Navigator.of(context).pop(); // Cerrar modal para que vea la pantalla
        }
      },
    );
  }

  Widget _buildProductCards(List<Producto> products) {
    return Column(
      children: products.map((prod) {
        final bool inStock = prod.stock > 0;
        final Color stockColor = prod.stock > 3
            ? Colors.green.shade600
            : (prod.stock > 0 ? Colors.orange.shade700 : Colors.red.shade600);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.turquesa.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  prod.tipo == 'armazon'
                      ? Icons.visibility
                      : (prod.tipo == 'mica' ? Icons.lens : Icons.inventory_2),
                  color: AppColors.azulReal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prod.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${prod.marca} ${prod.modelo.isNotEmpty ? '• ${prod.modelo}' : ''}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Stock: ${prod.stock}',
                          style: TextStyle(
                            color: stockColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          inStock ? 'Disponible' : 'Agotado',
                          style: TextStyle(
                            color: stockColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.azulReal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '\$${prod.precioVenta.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulReal,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatientCards(List<Paciente> patients) {
    return Column(
      children: patients.map((paciente) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.azulReal.withOpacity(0.1),
                child: Text(
                  paciente.nombre.isNotEmpty ? paciente.nombre[0].toUpperCase() : 'P',
                  style: TextStyle(
                    color: AppColors.azulReal,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paciente.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      paciente.telefono.isNotEmpty ? '📞 ${paciente.telefono}' : 'Sin teléfono',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (paciente.telefono.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.green, size: 20),
                  tooltip: 'WhatsApp',
                  onPressed: () {
                    WhatsAppHelper.contactar(
                      context,
                      telefono: paciente.telefono,
                      nombre: paciente.nombre,
                    );
                  },
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsBadge(Map<String, dynamic> stats) {
    final double total = (stats['totalVentasHoy'] ?? 0).toDouble();
    final int cantidad = (stats['ventasDelDia'] as List? ?? []).length;
    final int entregas = (stats['proximasEntregas'] as List? ?? []).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.azulReal.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.turquesa.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCol('Total Hoy', '\$${total.toStringAsFixed(0)}', AppColors.azulReal),
          _buildStatCol('Ventas', '$cantidad', AppColors.turquesa),
          _buildStatCol('Entregas', '$entregas', Colors.orange.shade800),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildQuickReplies(List<String> replies) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: replies.map((reply) {
        return ActionChip(
          label: Text(
            reply,
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.azulReal,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.white,
          side: BorderSide(color: AppColors.turquesa.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0.5,
          onPressed: () => _handleSubmitted(reply),
        );
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      color: const Color(0xFFF7F9FC),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.turquesa),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'El asistente está consultando...',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration(
                  hintText: 'Pregunta o escribe "¿dónde encuentro...?"',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.black45),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.azulReal, AppColors.azulCobalto],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
