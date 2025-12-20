import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/name_parser.dart';

/// Chiavi per SharedPreferences
class _AuthKeys {
  static const String email = 'auth_email';
  static const String isLoggedIn = 'auth_is_logged_in';
}

/// Stato dell'utente autenticato
class AuthState {
  final String? email;
  final bool isLoggedIn;
  final bool isInitialized;

  const AuthState({
    this.email,
    this.isLoggedIn = false,
    this.isInitialized = false,
  });

  /// Nome visualizzabile estratto dall'email
  String get displayName =>
      email != null ? NameParser.extractDisplayName(email!) : '';

  /// Solo il nome (per il saluto)
  String get firstName =>
      email != null ? NameParser.extractFirstName(email!) : '';

  AuthState copyWith({
    String? email,
    bool? isLoggedIn,
    bool? isInitialized,
  }) {
    return AuthState(
      email: email ?? this.email,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Notifier per gestire l'autenticazione
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadSavedAuth();
  }

  /// Carica lo stato di autenticazione salvato
  Future<void> _loadSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_AuthKeys.email);
    final savedIsLoggedIn = prefs.getBool(_AuthKeys.isLoggedIn) ?? false;

    state = AuthState(
      email: savedEmail,
      isLoggedIn: savedIsLoggedIn && savedEmail != null,
      isInitialized: true,
    );
  }

  /// Effettua il login salvando l'email
  Future<void> login(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_AuthKeys.email, email);
    await prefs.setBool(_AuthKeys.isLoggedIn, true);

    state = state.copyWith(
      email: email,
      isLoggedIn: true,
    );
  }

  /// Effettua il logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_AuthKeys.email);
    await prefs.setBool(_AuthKeys.isLoggedIn, false);

    state = AuthState(isInitialized: state.isInitialized);
  }
}

/// Provider per lo stato di autenticazione
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
