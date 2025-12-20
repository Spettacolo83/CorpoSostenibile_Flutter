import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/gemini_service.dart';

/// Modello per un messaggio AI
class AIMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const AIMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Stato della chat AI
class AIChatState {
  final List<AIMessage> messages;
  final bool isTyping;
  final String? userName;

  const AIChatState({
    this.messages = const [],
    this.isTyping = false,
    this.userName,
  });

  AIChatState copyWith({
    List<AIMessage>? messages,
    bool? isTyping,
    String? userName,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      userName: userName ?? this.userName,
    );
  }
}

/// Provider per la chat AI
final aiChatProvider = StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  return AIChatNotifier();
});

/// Notifier per gestire la chat AI
class AIChatNotifier extends StateNotifier<AIChatState> {
  final GeminiService _gemini = GeminiService();

  AIChatNotifier() : super(const AIChatState());

  /// Imposta il nome dell'utente
  void setUserName(String name) {
    state = state.copyWith(userName: name);
  }

  /// Invia un messaggio
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Aggiungi messaggio utente
    final userMessage = AIMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    try {
      // Ottieni risposta da Gemini
      final response = await _gemini.sendMessage(text, userName: state.userName);

      final aiMessage = AIMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isTyping: false,
      );
    } catch (e) {
      final errorMessage = AIMessage(
        text: 'Si è verificato un errore. Riprova.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isTyping: false,
      );
    }
  }

  /// Resetta la chat
  void resetChat() {
    _gemini.resetChat();
    state = state.copyWith(messages: []);
  }
}
