# Architettura del Progetto

Questo documento descrive le scelte architetturali e i pattern utilizzati nell'applicazione Corpo Sostenibile.

---

## Riverpod - State Management

### Cos'è Riverpod

**Riverpod** è una libreria di state management per Flutter. Permette di gestire lo stato dell'applicazione in modo reattivo: quando un dato cambia, l'interfaccia si aggiorna automaticamente.

Rispetto ad altre soluzioni come Provider o BLoC, Riverpod offre maggiore sicurezza a compile-time e non dipende dal BuildContext, rendendo il codice più flessibile e facile da testare.

### Come è stato utilizzato nel progetto

L'app utilizza **StateNotifierProvider** per gestire stati complessi con logica di business:

#### 1. Autenticazione (`auth_provider.dart`)
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```
- Gestisce login/logout dell'utente
- Persiste lo stato su SharedPreferences
- Espone `displayName` e `firstName` estratti dall'email

#### 2. Tema (`theme_provider.dart`)
```dart
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeModeOption>((ref) {
  return ThemeNotifier();
});
```
- Gestisce light/dark/system mode
- Persiste la preferenza utente
- Permette di ciclare tra i temi

#### 3. Chat AI (`ai_chat_provider.dart`)
```dart
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final aiChatProvider = StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  return AIChatNotifier(ref.watch(geminiServiceProvider));
});
```
- Gestisce la lista messaggi e stato "typing"
- Il GeminiService viene iniettato come dipendenza, così nei test possiamo sostituirlo con un mock
- Lo stato è immutabile: ogni modifica crea una nuova istanza con `copyWith()`

### Pattern utilizzati

| Pattern | Descrizione |
|---------|-------------|
| **StateNotifier** | Classe che gestisce stato immutabile con logica |
| **Dependency Injection** | I servizi vengono iniettati tramite `ref.watch()` |
| **Immutability** | Lo stato viene aggiornato con `copyWith()`, mai modificato direttamente |

---

## Clean Architecture

### Cos'è Clean Architecture

La **Clean Architecture** è un modo di organizzare il codice in layer separati, dove ogni layer ha una responsabilità specifica. Il vantaggio principale è che puoi modificare una parte dell'app (ad esempio cambiare database o API) senza dover riscrivere tutto il resto.

In pratica, significa separare:
- **Dove prendi i dati** (API, database, cache)
- **Cosa fai con i dati** (logica di business)
- **Come mostri i dati** (UI)

### Struttura nel progetto

```
lib/
├── core/                      # Elementi condivisi tra feature
│   ├── config/               # Configurazioni (secrets)
│   ├── constants/            # Costanti globali
│   ├── errors/               # Gestione errori centralizzata
│   ├── network/              # Client HTTP (Dio)
│   ├── services/             # Servizi (Gemini AI)
│   ├── utils/                # Utility functions
│   └── widgets/              # Widget riutilizzabili
│
├── config/                    # Configurazione app
│   ├── routes/               # Routing (go_router)
│   └── theme/                # Design system e tema
│
└── features/                  # Feature organizzate per dominio
    ├── auth/
    ├── home/
    ├── progress/
    ├── chat/
    └── professionals/
```

### Struttura di ogni Feature (3 Layer)

```
feature/
├── data/                      # LAYER DATI
│   ├── datasources/          # Chiamate API, query database
│   ├── models/               # Modelli con serializzazione JSON
│   └── repositories/         # Implementazione concreta
│
├── domain/                    # LAYER DOMINIO (logica di business)
│   ├── entities/             # Oggetti puri, senza dipendenze
│   ├── repositories/         # Interfacce (contratti)
│   └── usecases/             # Azioni specifiche (es. "effettua login")
│
└── presentation/              # LAYER UI
    ├── pages/                # Schermate
    ├── widgets/              # Widget specifici della feature
    └── providers/            # State management (Riverpod)
```

### Come funziona in pratica

Immagina di dover mostrare i dati della dashboard:

1. **Presentation**: La `HomePage` chiede i dati al provider
2. **Domain**: Il provider usa uno UseCase `GetDashboardData`
3. **Data**: Lo UseCase chiama il Repository che fa la chiamata API
4. I dati risalgono fino alla UI

Se domani cambi l'API con un database locale, modifichi solo il layer Data. Il resto dell'app non cambia.

### Perché questa struttura

| Beneficio | In pratica |
|-----------|------------|
| **Testabilità** | Puoi testare la logica senza avviare l'app |
| **Manutenibilità** | Bug isolati, sai sempre dove cercare |
| **Scalabilità** | Aggiungere feature non complica il codice esistente |
| **Collaborazione** | Più sviluppatori possono lavorare su layer diversi |

### Esempio: Feature Home

```
home/
├── data/
│   ├── datasources/          # API calls per dashboard
│   ├── models/               # UserModel, DashboardModel (JSON)
│   └── repositories/         # HomeRepositoryImpl
│
├── domain/
│   ├── entities/             # User, DashboardData (oggetti puri)
│   ├── repositories/         # IHomeRepository (interfaccia)
│   └── usecases/             # GetDashboardData, GetUserProfile
│
└── presentation/
    ├── pages/                # HomePage
    ├── widgets/              # DashboardCard, QuickActions
    └── providers/            # AIChatProvider
```

---

## Risorse utili

- [Riverpod Documentation](https://riverpod.dev/)
- [Flutter Clean Architecture Guide](https://resocoder.com/flutter-clean-architecture-tdd/)
