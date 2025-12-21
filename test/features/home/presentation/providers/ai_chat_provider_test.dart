import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:corpo_sostenibile/core/services/gemini_service.dart';
import 'package:corpo_sostenibile/features/home/presentation/providers/ai_chat_provider.dart';

/// Mock per GeminiService
class MockGeminiService extends Mock implements GeminiService {}

void main() {
  late MockGeminiService mockGeminiService;
  late AIChatNotifier notifier;

  setUp(() {
    mockGeminiService = MockGeminiService();
    notifier = AIChatNotifier(mockGeminiService);
  });

  group('AIChatNotifier', () {
    group('stato iniziale', () {
      test('ha lista messaggi vuota', () {
        expect(notifier.state.messages, isEmpty);
      });

      test('non sta scrivendo', () {
        expect(notifier.state.isTyping, isFalse);
      });

      test('userName è null', () {
        expect(notifier.state.userName, isNull);
      });
    });

    group('setUserName', () {
      test('imposta il nome utente', () {
        notifier.setUserName('Stefano');

        expect(notifier.state.userName, 'Stefano');
      });

      test('aggiorna il nome utente esistente', () {
        notifier.setUserName('Mario');
        notifier.setUserName('Luigi');

        expect(notifier.state.userName, 'Luigi');
      });

      test('preserva i messaggi esistenti', () {
        // Setup: aggiungi un messaggio
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((_) async => 'Risposta');

        // Invia messaggio
        notifier.sendMessage('Test');

        // Poi cambia nome
        notifier.setUserName('Stefano');

        // I messaggi devono essere preservati
        expect(notifier.state.messages.length, greaterThanOrEqualTo(1));
        expect(notifier.state.userName, 'Stefano');
      });
    });

    group('sendMessage', () {
      test('ignora messaggi vuoti', () async {
        await notifier.sendMessage('');

        expect(notifier.state.messages, isEmpty);
        verifyNever(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            ));
      });

      test('ignora messaggi con solo spazi', () async {
        await notifier.sendMessage('   ');

        expect(notifier.state.messages, isEmpty);
        verifyNever(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            ));
      });

      test('aggiunge messaggio utente alla lista', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((_) async => 'Risposta AI');

        await notifier.sendMessage('Ciao');

        expect(notifier.state.messages.length, 2);
        expect(notifier.state.messages[0].text, 'Ciao');
        expect(notifier.state.messages[0].isUser, isTrue);
      });

      test('aggiunge risposta AI alla lista', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((_) async => 'Ciao! Come posso aiutarti?');

        await notifier.sendMessage('Ciao');

        expect(notifier.state.messages.length, 2);
        expect(notifier.state.messages[1].text, 'Ciao! Come posso aiutarti?');
        expect(notifier.state.messages[1].isUser, isFalse);
      });

      test('imposta isTyping a true durante la richiesta', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((_) async {
          // Simula ritardo
          await Future.delayed(const Duration(milliseconds: 100));
          return 'Risposta';
        });

        // Avvia senza await
        final future = notifier.sendMessage('Test');

        // Durante l'attesa, isTyping deve essere true
        await Future.delayed(const Duration(milliseconds: 10));
        expect(notifier.state.isTyping, isTrue);

        // Aspetta completamento
        await future;

        // Dopo, isTyping deve essere false
        expect(notifier.state.isTyping, isFalse);
      });

      test('passa il nome utente a GeminiService', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((_) async => 'Risposta');

        notifier.setUserName('Mario');
        await notifier.sendMessage('Ciao');

        verify(() => mockGeminiService.sendMessage(
              'Ciao',
              userName: 'Mario',
            )).called(1);
      });

      test('gestisce errori e mostra messaggio di errore', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenThrow(Exception('Network error'));

        await notifier.sendMessage('Test');

        expect(notifier.state.messages.length, 2);
        expect(notifier.state.messages[1].text, 'Si è verificato un errore. Riprova.');
        expect(notifier.state.messages[1].isUser, isFalse);
        expect(notifier.state.isTyping, isFalse);
      });

      test('messaggi hanno timestamp crescenti', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((_) async => 'Risposta');

        await notifier.sendMessage('Primo');
        await notifier.sendMessage('Secondo');

        final timestamps = notifier.state.messages.map((m) => m.timestamp).toList();

        // Verifica ordine cronologico
        for (var i = 0; i < timestamps.length - 1; i++) {
          expect(
            timestamps[i].isBefore(timestamps[i + 1]) ||
                timestamps[i].isAtSameMomentAs(timestamps[i + 1]),
            isTrue,
          );
        }
      });

      test('conversazione multipla mantiene storico', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((invocation) async {
          final msg = invocation.positionalArguments[0] as String;
          return 'Risposta a: $msg';
        });

        await notifier.sendMessage('Domanda 1');
        await notifier.sendMessage('Domanda 2');
        await notifier.sendMessage('Domanda 3');

        expect(notifier.state.messages.length, 6); // 3 user + 3 AI
        expect(notifier.state.messages[0].text, 'Domanda 1');
        expect(notifier.state.messages[1].text, 'Risposta a: Domanda 1');
        expect(notifier.state.messages[2].text, 'Domanda 2');
        expect(notifier.state.messages[3].text, 'Risposta a: Domanda 2');
      });
    });

    group('resetChat', () {
      test('svuota la lista messaggi', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((_) async => 'Risposta');
        when(() => mockGeminiService.resetChat()).thenReturn(null);

        await notifier.sendMessage('Test');
        expect(notifier.state.messages, isNotEmpty);

        notifier.resetChat();

        expect(notifier.state.messages, isEmpty);
      });

      test('chiama resetChat su GeminiService', () async {
        when(() => mockGeminiService.resetChat()).thenReturn(null);

        notifier.resetChat();

        verify(() => mockGeminiService.resetChat()).called(1);
      });

      test('preserva userName dopo reset', () async {
        when(() => mockGeminiService.sendMessage(
              any(),
              userName: any(named: 'userName'),
            )).thenAnswer((_) async => 'Risposta');
        when(() => mockGeminiService.resetChat()).thenReturn(null);

        notifier.setUserName('Stefano');
        await notifier.sendMessage('Test');
        notifier.resetChat();

        expect(notifier.state.messages, isEmpty);
        expect(notifier.state.userName, 'Stefano');
      });
    });
  });

  group('AIChatState', () {
    test('copyWith crea copia corretta', () {
      const original = AIChatState(
        messages: [],
        isTyping: false,
        userName: 'Test',
      );

      final modified = original.copyWith(isTyping: true);

      expect(modified.isTyping, isTrue);
      expect(modified.userName, 'Test'); // Preservato
      expect(modified.messages, isEmpty); // Preservato
    });

    test('copyWith con tutti i parametri', () {
      const original = AIChatState();
      final message = AIMessage(
        text: 'Test',
        isUser: true,
        timestamp: DateTime.now(),
      );

      final modified = original.copyWith(
        messages: [message],
        isTyping: true,
        userName: 'Mario',
      );

      expect(modified.messages.length, 1);
      expect(modified.isTyping, isTrue);
      expect(modified.userName, 'Mario');
    });
  });

  group('AIMessage', () {
    test('crea messaggio utente correttamente', () {
      final now = DateTime.now();
      final message = AIMessage(
        text: 'Ciao',
        isUser: true,
        timestamp: now,
      );

      expect(message.text, 'Ciao');
      expect(message.isUser, isTrue);
      expect(message.timestamp, now);
    });

    test('crea messaggio AI correttamente', () {
      final message = AIMessage(
        text: 'Risposta',
        isUser: false,
        timestamp: DateTime.now(),
      );

      expect(message.text, 'Risposta');
      expect(message.isUser, isFalse);
    });
  });
}
