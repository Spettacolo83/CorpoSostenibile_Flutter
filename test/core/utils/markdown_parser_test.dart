import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:corpo_sostenibile/core/utils/markdown_parser.dart';

void main() {
  group('MarkdownParser', () {
    group('parse - testo semplice', () {
      test('restituisce testo invariato senza markdown', () {
        const input = 'Ciao, questo è un testo semplice.';
        final spans = MarkdownParser.parse(input);

        expect(spans.length, 1);
        expect(spans.first.text, input);
        expect(spans.first.style, isNull);
      });

      test('gestisce stringa vuota', () {
        final spans = MarkdownParser.parse('');

        expect(spans.length, 1);
        expect(spans.first.text, '');
      });

      test('preserva spazi e newline', () {
        const input = 'Prima riga\n\nSeconda riga';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, contains('Prima riga'));
        expect(text, contains('Seconda riga'));
      });
    });

    group('parse - bold (**text**)', () {
      test('converte **testo** in bold', () {
        const input = 'Questo è **importante**!';
        final spans = MarkdownParser.parse(input);

        expect(spans.length, 3);
        expect(spans[0].text, 'Questo è ');
        expect(spans[1].text, 'importante');
        expect(spans[1].style?.fontWeight, FontWeight.bold);
        expect(spans[2].text, '!');
      });

      test('gestisce multipli bold nella stessa riga', () {
        const input = '**Primo** e **Secondo** bold';
        final spans = MarkdownParser.parse(input);

        final boldSpans =
            spans.where((s) => s.style?.fontWeight == FontWeight.bold).toList();
        expect(boldSpans.length, 2);
        expect(boldSpans[0].text, 'Primo');
        expect(boldSpans[1].text, 'Secondo');
      });

      test('gestisce bold con spazi interni', () {
        const input = '**testo con spazi**';
        final spans = MarkdownParser.parse(input);

        expect(spans.length, 1);
        expect(spans.first.text, 'testo con spazi');
        expect(spans.first.style?.fontWeight, FontWeight.bold);
      });

      test('ignora asterischi singoli nel bold', () {
        const input = '**bold con * asterisco**';
        final spans = MarkdownParser.parse(input);

        // Dovrebbe gestire correttamente
        final text = MarkdownParser.extractText(spans);
        expect(text, isNot(contains('**')));
      });
    });

    group('parse - italic (*text*)', () {
      test('converte *testo* in italic', () {
        const input = 'Questo è *enfatizzato* qui';
        final spans = MarkdownParser.parse(input);

        final italicSpans =
            spans.where((s) => s.style?.fontStyle == FontStyle.italic).toList();
        expect(italicSpans.length, 1);
        expect(italicSpans.first.text, 'enfatizzato');
      });

      test('gestisce multipli italic', () {
        const input = '*primo* normale *secondo*';
        final spans = MarkdownParser.parse(input);

        final italicSpans =
            spans.where((s) => s.style?.fontStyle == FontStyle.italic).toList();
        expect(italicSpans.length, 2);
      });

      test('distingue bold da italic', () {
        const input = '**bold** e *italic*';
        final spans = MarkdownParser.parse(input);

        final boldSpans =
            spans.where((s) => s.style?.fontWeight == FontWeight.bold).toList();
        final italicSpans =
            spans.where((s) => s.style?.fontStyle == FontStyle.italic).toList();

        expect(boldSpans.length, 1);
        expect(boldSpans.first.text, 'bold');
        expect(italicSpans.length, 1);
        expect(italicSpans.first.text, 'italic');
      });
    });

    group('parse - code (`text`)', () {
      test('converte `testo` in code', () {
        const input = 'Usa il comando `flutter run`';
        final spans = MarkdownParser.parse(input);

        final codeSpans =
            spans.where((s) => s.style?.fontFamily == 'monospace').toList();
        expect(codeSpans.length, 1);
        expect(codeSpans.first.text, 'flutter run');
      });

      test('gestisce multipli code inline', () {
        const input = '`primo` e `secondo` comando';
        final spans = MarkdownParser.parse(input);

        final codeSpans =
            spans.where((s) => s.style?.fontFamily == 'monospace').toList();
        expect(codeSpans.length, 2);
      });
    });

    group('parse - headers (#, ##, ###)', () {
      test('rimuove # da titoli', () {
        const input = '# Titolo principale';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('#')));
        expect(text, contains('Titolo principale'));
      });

      test('rimuove ## da sottotitoli', () {
        const input = '## Sottotitolo';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('#')));
        expect(text, contains('Sottotitolo'));
      });

      test('rimuove ### da sotto-sottotitoli', () {
        const input = '### Sezione';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('#')));
        expect(text, contains('Sezione'));
      });

      test('gestisce header con emoji', () {
        const input = '## 🍎 Alimentazione';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('##')));
        expect(text, contains('🍎'));
        expect(text, contains('Alimentazione'));
      });
    });

    group('parse - liste (* item)', () {
      test('converte * in bullet point •', () {
        const input = '* Primo elemento\n* Secondo elemento';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, contains('•'));
        expect(text, isNot(startsWith('*')));
        expect(text, contains('Primo elemento'));
        expect(text, contains('Secondo elemento'));
      });

      test('non converte * nel mezzo del testo', () {
        const input = 'Questo * non è una lista';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        // L'asterisco isolato viene rimosso come pattern rotto
        expect(text, isNot(contains('•')));
      });
    });

    group('parse - citazioni (> text)', () {
      test('rimuove > dalle citazioni', () {
        const input = '> Questa è una citazione';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('>')));
        expect(text, contains('Questa è una citazione'));
      });
    });

    group('parse - code blocks (```)', () {
      test('rimuove blocchi ```markdown', () {
        const input = '```markdown\nContenuto\n```';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('```')));
        expect(text, isNot(contains('markdown')));
        expect(text, contains('Contenuto'));
      });

      test('rimuove blocchi ``` generici', () {
        const input = '```\ncodice\n```';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('```')));
        expect(text, contains('codice'));
      });
    });

    group('parse - linee orizzontali (---)', () {
      test('rimuove linee orizzontali', () {
        const input = 'Prima\n---\nDopo';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('---')));
        expect(text, contains('Prima'));
        expect(text, contains('Dopo'));
      });
    });

    group('parse - pattern rotti', () {
      test('rimuove asterischi orfani', () {
        const input = 'Testo ** incompleto';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('**')));
        expect(text, contains('Testo'));
        expect(text, contains('incompleto'));
      });

      test('rimuove asterisco singolo orfano', () {
        const input = 'Testo * isolato';
        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('*')));
      });

      test('gestisce pattern misti corretti e rotti', () {
        const input = '**bold** e ** rotto';
        final spans = MarkdownParser.parse(input);

        final boldSpans =
            spans.where((s) => s.style?.fontWeight == FontWeight.bold).toList();
        expect(boldSpans.length, 1);
        expect(boldSpans.first.text, 'bold');

        final text = MarkdownParser.extractText(spans);
        expect(text, isNot(contains('**')));
      });
    });

    group('parse - baseColor', () {
      test('applica colore ai testi formattati', () {
        const input = '**bold** e *italic*';
        const testColor = Colors.red;
        final spans = MarkdownParser.parse(input, baseColor: testColor);

        final boldSpan =
            spans.firstWhere((s) => s.style?.fontWeight == FontWeight.bold);
        final italicSpan =
            spans.firstWhere((s) => s.style?.fontStyle == FontStyle.italic);

        expect(boldSpan.style?.color, testColor);
        expect(italicSpan.style?.color, testColor);
      });

      test('funziona senza colore specificato', () {
        const input = '**bold**';
        final spans = MarkdownParser.parse(input);

        expect(spans.first.style?.fontWeight, FontWeight.bold);
        expect(spans.first.style?.color, isNull);
      });
    });

    group('extractText', () {
      test('estrae testo puro da spans', () {
        final spans = [
          const TextSpan(text: 'Hello '),
          const TextSpan(
            text: 'World',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: '!'),
        ];

        expect(MarkdownParser.extractText(spans), 'Hello World!');
      });

      test('gestisce spans vuoti', () {
        final spans = <TextSpan>[];
        expect(MarkdownParser.extractText(spans), '');
      });
    });

    group('parse - casi reali da Gemini', () {
      test('messaggio con formattazione mista', () {
        const input = '''Ciao **Stefano**! Ecco alcuni consigli:

* **Idratazione**: Bevi *almeno* 2 litri d'acqua
* **Movimento**: Anche 15 minuti fanno la differenza

> "Il benessere inizia dalle piccole abitudini"

Per domande specifiche, contatta **Alice P.** (nutrizionista).''';

        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        // Verifica rimozione markdown
        expect(text, isNot(contains('**')));
        expect(text, isNot(contains('>')));

        // Verifica contenuto preservato
        expect(text, contains('Stefano'));
        expect(text, contains('Idratazione'));
        expect(text, contains('Alice P.'));

        // Verifica bullet points
        expect(text, contains('•'));

        // Verifica formattazione
        final boldSpans =
            spans.where((s) => s.style?.fontWeight == FontWeight.bold).toList();
        expect(boldSpans.length, greaterThan(0));

        final italicSpans =
            spans.where((s) => s.style?.fontStyle == FontStyle.italic).toList();
        expect(italicSpans.length, greaterThan(0));
      });

      test('messaggio con code block wrapper', () {
        const input = '''```markdown
# Titolo
**Testo bold**
```''';

        final spans = MarkdownParser.parse(input);
        final text = MarkdownParser.extractText(spans);

        expect(text, isNot(contains('```')));
        expect(text, isNot(contains('#')));
        expect(text, contains('Titolo'));
      });
    });
  });
}
