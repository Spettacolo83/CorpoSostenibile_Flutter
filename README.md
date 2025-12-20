# Corpo Sostenibile - App Mobile

App mobile per **Corpo Sostenibile**, il #1 Centro Online di Nutrizione Integrativa.

## Descrizione

Applicazione Flutter cross-platform (iOS/Android) per la gestione del percorso di benessere e nutrizione degli utenti. L'app consente di:

- Gestire appuntamenti con i professionisti
- Visualizzare e seguire il piano alimentare personalizzato
- Tracciare i progressi del percorso
- Comunicare con il team di supporto
- Accedere a risorse educative

## Architettura

Il progetto segue i principi della **Clean Architecture** per garantire:

- Separazione delle responsabilità
- Testabilità del codice
- Manutenibilità a lungo termine
- Scalabilità delle funzionalità

### Struttura del Progetto

```
lib/
├── config/                    # Configurazioni app
│   ├── routes/               # Routing (go_router)
│   └── theme/                # Tema e design system
│
├── core/                      # Elementi condivisi
│   ├── constants/            # Costanti globali
│   ├── errors/               # Gestione errori (Failures/Exceptions)
│   ├── network/              # Client API (Dio)
│   ├── utils/                # Utility functions
│   └── widgets/              # Widget riutilizzabili
│
├── features/                  # Feature dell'app (per modulo)
│   ├── auth/                 # Autenticazione
│   │   ├── data/            # Layer dati
│   │   │   ├── datasources/ # API e cache
│   │   │   ├── models/      # Data models (JSON)
│   │   │   └── repositories/# Implementazioni repository
│   │   ├── domain/          # Layer business logic
│   │   │   ├── entities/    # Entità di dominio
│   │   │   ├── repositories/# Interfacce repository
│   │   │   └── usecases/    # Casi d'uso
│   │   └── presentation/    # Layer UI
│   │       ├── pages/       # Schermate
│   │       ├── widgets/     # Widget specifici
│   │       └── providers/   # State (Riverpod)
│   │
│   └── home/                 # Home/Dashboard
│       └── ...              # Stessa struttura
│
└── main.dart                  # Entry point
```

## Stack Tecnologico

| Categoria | Tecnologia |
|-----------|------------|
| **Framework** | Flutter 3.29+ |
| **State Management** | Riverpod 2.x |
| **Routing** | go_router |
| **HTTP Client** | Dio + Retrofit |
| **Storage Sicuro** | flutter_secure_storage |
| **Serializzazione** | freezed + json_serializable |
| **Testing** | mocktail |

## Requisiti

- Flutter SDK >= 3.7.2
- Dart SDK >= 3.7.2
- Xcode (per iOS)
- Android Studio (per Android)

## Installazione

1. **Clona il repository**
   ```bash
   git clone git@github.com:Spettacolo83/CorpoSostenibile_Flutter.git
   cd CorpoSostenibile_Flutter
   ```

2. **Installa le dipendenze**
   ```bash
   flutter pub get
   ```

3. **Genera il codice (models, providers)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Esegui l'app**
   ```bash
   # Debug
   flutter run

   # iOS Simulator
   flutter run -d ios

   # Android Emulator
   flutter run -d android
   ```

## Comandi Utili

```bash
# Analisi statica del codice
flutter analyze

# Esegui test
flutter test

# Esegui test con coverage
flutter test --coverage

# Build release Android
flutter build apk --release

# Build release iOS
flutter build ios --release

# Generazione continua del codice
flutter pub run build_runner watch
```

## Design System

L'app utilizza un design system coerente basato su Material 3:

### Colori Principali
- **Primary**: Verde (#2E7D32) - Natura e salute
- **Secondary**: Arancione (#FF8F00) - Energia e vitalità
- **Accent**: Teal (#00897B) - Equilibrio

### Tipografia
- Font: **Poppins** (Google Fonts)
- Supporto completo per tema chiaro/scuro

## Testing

Il progetto include test per ogni layer:

```
test/
├── core/                # Test utilities core
├── features/
│   ├── auth/
│   │   ├── data/       # Test datasources e repositories
│   │   ├── domain/     # Test usecases
│   │   └── presentation/ # Widget test
│   └── home/
└── helpers/            # Test utilities
```

## Convenzioni di Codice

- **Lingua codice**: Inglese
- **Documentazione**: Italiano
- **Naming**: camelCase per variabili, PascalCase per classi
- **File**: snake_case
- **Lint**: seguire le regole di `flutter_lints`

## Roadmap

- [x] Setup progetto e architettura
- [x] Configurazione tema e design system
- [x] Pagina splash e login
- [x] Home page con dashboard
- [ ] Autenticazione JWT/OAuth2
- [ ] Integrazione API REST (Flask)
- [ ] Profilo utente
- [ ] Piano alimentare
- [ ] Sistema notifiche
- [ ] Chat con supporto

## Autore

Sviluppato per **Corpo Sostenibile** - Centro Online di Nutrizione Integrativa

---

*Mockup realizzato per dimostrazione competenze Flutter Developer*
