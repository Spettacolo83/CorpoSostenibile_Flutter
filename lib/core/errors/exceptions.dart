/// Eccezioni personalizzate per la gestione degli errori
library;

/// Eccezione per errori del server
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    this.message = 'Errore del server',
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

/// Eccezione per errori di rete
class NetworkException implements Exception {
  final String message;

  const NetworkException({
    this.message = 'Errore di connessione alla rete',
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Eccezione per errori di autenticazione
class AuthException implements Exception {
  final String message;

  const AuthException({
    this.message = 'Errore di autenticazione',
  });

  @override
  String toString() => 'AuthException: $message';
}

/// Eccezione per errori nella cache
class CacheException implements Exception {
  final String message;

  const CacheException({
    this.message = 'Errore nella cache locale',
  });

  @override
  String toString() => 'CacheException: $message';
}
