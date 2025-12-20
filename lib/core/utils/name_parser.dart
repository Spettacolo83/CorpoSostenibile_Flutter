/// Utility per estrarre e formattare il nome dall'email
class NameParser {
  NameParser._();

  /// Estrae il nome visualizzabile dall'email.
  /// Prova a parsare nome.cognome, nome_cognome, ecc.
  /// Se non riesce, usa il nickname con prima lettera maiuscola.
  static String extractDisplayName(String email) {
    if (email.isEmpty) return '';

    // Prende la parte prima della @
    final localPart = email.split('@').first;

    // Prova a separare per . o _ o -
    final separators = ['.', '_', '-'];
    for (final sep in separators) {
      if (localPart.contains(sep)) {
        final parts = localPart.split(sep);
        if (parts.length >= 2) {
          // Prende le prime due parti come nome e cognome
          final firstName = _capitalize(parts[0]);
          final lastName = _capitalize(parts[1]);
          return '$firstName $lastName';
        }
      }
    }

    // Se non ci sono separatori, usa il localPart come nickname
    return _capitalize(localPart);
  }

  /// Estrae solo il nome (prima parte) dall'email
  static String extractFirstName(String email) {
    final displayName = extractDisplayName(email);
    return displayName.split(' ').first;
  }

  /// Rende maiuscola la prima lettera
  static String _capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
