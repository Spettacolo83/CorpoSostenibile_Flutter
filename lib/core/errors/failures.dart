import 'package:equatable/equatable.dart';

/// Classe base per la gestione degli errori in modo funzionale.
/// Utilizzata con il pattern Either di dartz.
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Errore di connessione alla rete
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Errore di connessione. Verifica la tua rete.',
    super.code,
  });
}

/// Errore dal server API
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Errore del server. Riprova più tardi.',
    super.code,
  });
}

/// Errore di autenticazione
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Sessione scaduta. Effettua nuovamente l\'accesso.',
    super.code,
  });
}

/// Errore nella cache locale
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Errore nella lettura dei dati locali.',
    super.code,
  });
}

/// Errore di validazione dati
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Errore generico sconosciuto
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Si è verificato un errore imprevisto.',
    super.code,
  });
}
