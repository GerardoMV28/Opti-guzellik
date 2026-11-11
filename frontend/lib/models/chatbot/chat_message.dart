import '../productos/producto_model.dart';
import '../pacientes/paciente_model.dart';

enum ChatbotActionType {
  navigation,
  custom,
}

class ChatbotAction {
  final String label;
  final ChatbotActionType type;
  final int? targetIndex;
  final String? route;

  ChatbotAction({
    required this.label,
    this.type = ChatbotActionType.navigation,
    this.targetIndex,
    this.route,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final ChatbotAction? action;
  final List<Producto>? productResults;
  final List<Paciente>? patientResults;
  final Map<String, dynamic>? statsResult;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies,
    this.action,
    this.productResults,
    this.patientResults,
    this.statsResult,
  });
}
