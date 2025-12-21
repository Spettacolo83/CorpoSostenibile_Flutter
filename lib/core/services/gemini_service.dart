import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Servizio per l'interazione con Gemini AI
class GeminiService {
  /// API Key per Google AI Studio (Gemini)
  /// Passa la key durante la build con: --dart-define=GEMINI_API_KEY=your_key
  /// Ottieni la tua API key da: https://aistudio.google.com/apikey
  static const apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Nome del modello Gemini da utilizzare
  static const modelName = 'gemini-flash-latest';

  /// System Prompt per l'assistente AI
  /// Modifica questo prompt per personalizzare il comportamento dell'assistente
  /// Usa {userName} come placeholder per il nome dell'utente
  static const systemPrompt = '''
Sei l'assistente AI di Corpo Sostenibile, un centro online di nutrizione integrativa.
Il tuo ruolo è supportare gli utenti nel loro percorso di benessere in modo empatico e professionale.

UTENTE ATTUALE: {userName}

LINEE GUIDA:
- Rispondi sempre in italiano
- Sii cordiale, empatico e incoraggiante
- Usa il nome dell'utente quando appropriato per rendere la conversazione più personale
- Fornisci consigli generali su nutrizione, benessere e stile di vita sano
- NON fornire diagnosi mediche o piani alimentari specifici
- Per questioni specifiche, suggerisci di consultare i professionisti del team:
  * Alice P. - Nutrizionista
  * Lorenzo S. - Coach
  * Delia D.S. - Psicologa Alimentare
- Mantieni le risposte concise (2-4 frasi) a meno che non sia necessario approfondire
- Usa un tono positivo e motivante

TEMI CHE PUOI AFFRONTARE:
- Consigli generali su alimentazione equilibrata
- Suggerimenti per spuntini sani
- Motivazione e supporto emotivo
- Importanza dell'idratazione
- Benefici dell'attività fisica
- Mindfulness e gestione dello stress legato al cibo
- Risposte a domande frequenti sul benessere

FORMATO RISPOSTE:
- NON usare blocchi di codice (```) nelle risposte
- Puoi usare **grassetto** e *corsivo* per enfatizzare
- Rispondi in modo diretto senza wrappare il testo in markdown code blocks

IMPORTANTE: Sei parte di un'app demo e i professionisti menzionati sono personaggi fittizi.
''';

  GenerativeModel? _model;
  String? _currentUserName;

  /// Storico della conversazione (gestito manualmente)
  final List<_ChatMessage> _history = [];

  static final GeminiService _instance = GeminiService._internal();

  factory GeminiService() => _instance;

  GeminiService._internal();

  /// Inizializza il modello con il system prompt personalizzato
  void _initializeModel({String? userName}) {
    _currentUserName = userName;
    final personalizedPrompt = systemPrompt.replaceAll(
      '{userName}',
      userName ?? 'Utente',
    );

    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.text(personalizedPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1024,
      ),
    );
  }

  /// Costruisce il prompt completo con lo storico della conversazione
  String _buildPromptWithHistory(String newMessage) {
    final buffer = StringBuffer();

    // Aggiungi lo storico
    for (final msg in _history) {
      if (msg.isUser) {
        buffer.writeln('Utente: ${msg.text}');
      } else {
        buffer.writeln('Assistente: ${msg.text}');
      }
    }

    // Aggiungi il nuovo messaggio
    buffer.writeln('Utente: $newMessage');
    buffer.writeln('Assistente:');

    return buffer.toString();
  }

  /// Invia un messaggio e ottiene una risposta
  /// [userName] - Nome dell'utente per personalizzare le risposte
  Future<String> sendMessage(String message, {String? userName}) async {
    try {
      // Se il modello non esiste o il nome utente è cambiato, reinizializza
      if (_model == null || userName != _currentUserName) {
        _initializeModel(userName: userName);
      }

      // Costruisci il prompt con lo storico
      final fullPrompt = _history.isEmpty
          ? message
          : _buildPromptWithHistory(message);

      debugPrint('=== GEMINI REQUEST ===');
      debugPrint('Chars: ${fullPrompt.length}');

      // Usa generateContent invece di ChatSession
      final response = await _model!.generateContent([Content.text(fullPrompt)]);
      final text = response.text;

      debugPrint('=== GEMINI RESPONSE ===');
      debugPrint('Chars: ${text?.length ?? 0}');
      debugPrint('=== FULL TEXT START ===');
      // Stampa in blocchi per evitare troncamento
      if (text != null) {
        for (var i = 0; i < text.length; i += 500) {
          final end = (i + 500 < text.length) ? i + 500 : text.length;
          debugPrint(text.substring(i, end));
        }
      }
      debugPrint('=== FULL TEXT END ===');

      if (text == null || text.isEmpty) {
        return 'Mi dispiace, non sono riuscito a elaborare la risposta. Riprova.';
      }

      // Salva nello storico
      _history.add(_ChatMessage(text: message, isUser: true));
      _history.add(_ChatMessage(text: text, isUser: false));

      return text;
    } on ServerException catch (e) {
      debugPrint('ServerException: ${e.message}');
      return 'Errore server: ${e.message}';
    } on GenerativeAIException catch (e) {
      debugPrint('GenerativeAIException: ${e.message}');
      return _handleGenerativeAIError(e.message);
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      return _handleGenericError(e.toString());
    }
  }

  String _handleGenerativeAIError(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('api key') || lowerMessage.contains('api_key')) {
      return 'Errore: API Key non valida.';
    }
    if (lowerMessage.contains('not found') || lowerMessage.contains('404')) {
      return 'Modello "$modelName" non trovato.';
    }
    if (lowerMessage.contains('quota') || lowerMessage.contains('rate')) {
      return 'Limite richieste raggiunto. Riprova tra poco.';
    }
    if (lowerMessage.contains('safety') || lowerMessage.contains('blocked')) {
      return 'Non posso rispondere a questa domanda.';
    }
    if (lowerMessage.contains('permission')) {
      return 'API key senza permessi per questo modello.';
    }

    return 'Errore AI: $message';
  }

  String _handleGenericError(String errorString) {
    final lowerError = errorString.toLowerCase();

    if (lowerError.contains('socket') || lowerError.contains('connection')) {
      return 'Errore di connessione. Controlla internet.';
    }
    if (lowerError.contains('timeout')) {
      return 'Timeout. Riprova.';
    }
    if (lowerError.contains('404')) {
      _model = null;
      return 'Modello non disponibile (404).';
    }

    return 'Errore: ${errorString.length > 150 ? '${errorString.substring(0, 150)}...' : errorString}';
  }

  /// Reset della conversazione
  void resetChat() {
    _history.clear();
  }

  /// Verifica se il servizio è configurato
  bool get isConfigured => apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE';
}

/// Messaggio interno per lo storico
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
