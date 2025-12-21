import 'package:flutter/material.dart';

/// Parser per convertire testo Markdown in TextSpan formattati.
/// Supporta: **bold**, *italic*, `code`, ## headers, * liste, > citazioni
class MarkdownParser {
  /// Converte testo markdown in una lista di TextSpan formattati.
  ///
  /// [text] - Il testo markdown da parsare
  /// [baseColor] - Colore base per il testo formattato
  ///
  /// Restituisce una lista di TextSpan con la formattazione appropriata.
  static List<TextSpan> parse(String text, {Color? baseColor}) {
    // Pre-processa il testo per gestire markdown a livello di riga
    var processed = text;

    // Rimuovi blocchi ```markdown e ``` (code blocks)
    processed = processed.replaceAll(RegExp(r'```\w*\n?'), '');
    processed = processed.replaceAll('```', '');

    // Rimuovi --- (linea orizzontale)
    processed = processed.replaceAll(RegExp(r'^-{3,}$', multiLine: true), '');

    // Rimuovi ### ## # dai titoli (in ordine da più lungo a più corto)
    processed = processed.replaceAll(RegExp(r'^###\s+', multiLine: true), '');
    processed = processed.replaceAll(RegExp(r'^##\s+', multiLine: true), '');
    processed = processed.replaceAll(RegExp(r'^#\s+', multiLine: true), '');

    // Converti liste puntate "* testo" a inizio riga in "• testo"
    processed = processed.replaceAllMapped(
      RegExp(r'^(\*)\s+', multiLine: true),
      (m) => '• ',
    );

    // Converti citazioni "> testo" rimuovendo il >
    processed = processed.replaceAll(RegExp(r'^>\s*', multiLine: true), '');

    // Gestisci **text** (bold) sostituendo con placeholder
    final boldMatches = <String, String>{};
    var boldIndex = 0;
    processed = processed.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (m) {
        final key = '\u0001BOLD$boldIndex\u0001';
        boldMatches[key] = m.group(1)!;
        boldIndex++;
        return key;
      },
    );

    // Gestisci *text* (italic)
    final italicMatches = <String, String>{};
    var italicIndex = 0;
    processed = processed.replaceAllMapped(
      RegExp(r'\*([^*]+)\*'),
      (m) {
        final key = '\u0002ITALIC$italicIndex\u0002';
        italicMatches[key] = m.group(1)!;
        italicIndex++;
        return key;
      },
    );

    // Gestisci `code`
    final codeMatches = <String, String>{};
    var codeIndex = 0;
    processed = processed.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (m) {
        final key = '\u0003CODE$codeIndex\u0003';
        codeMatches[key] = m.group(1)!;
        codeIndex++;
        return key;
      },
    );

    // Rimuovi asterischi rimasti (pattern rotti)
    processed = processed.replaceAll(RegExp(r'\*+'), '');

    // Costruisci gli spans
    final List<TextSpan> spans = [];
    final allPlaceholders = RegExp(
      r'\u0001BOLD\d+\u0001|\u0002ITALIC\d+\u0002|\u0003CODE\d+\u0003',
    );

    int lastEnd = 0;
    for (final match in allPlaceholders.allMatches(processed)) {
      // Testo normale prima del placeholder
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: processed.substring(lastEnd, match.start)));
      }

      final placeholder = match.group(0)!;
      if (placeholder.startsWith('\u0001')) {
        // Bold
        spans.add(TextSpan(
          text: boldMatches[placeholder],
          style: TextStyle(fontWeight: FontWeight.bold, color: baseColor),
        ));
      } else if (placeholder.startsWith('\u0002')) {
        // Italic
        spans.add(TextSpan(
          text: italicMatches[placeholder],
          style: TextStyle(fontStyle: FontStyle.italic, color: baseColor),
        ));
      } else if (placeholder.startsWith('\u0003')) {
        // Code
        spans.add(TextSpan(
          text: codeMatches[placeholder],
          style: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: baseColor?.withValues(alpha: 0.1),
            color: baseColor,
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Testo rimanente
    if (lastEnd < processed.length) {
      spans.add(TextSpan(text: processed.substring(lastEnd)));
    }

    // Se non c'erano match, restituisci il testo
    if (spans.isEmpty) {
      spans.add(TextSpan(text: processed));
    }

    return spans;
  }

  /// Estrae il testo puro da una lista di TextSpan (utile per test)
  static String extractText(List<TextSpan> spans) {
    return spans.map((s) => s.text ?? '').join();
  }
}
