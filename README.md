# Uomo in 90 Giorni - Mental Coach Stoico

Un'app Flutter per la crescita personale basata sulla filosofia stoica. Mental Coach che ti sfida con domande scomode e ti aiuta a diventare la versione migliore di te stesso.

## Funzionalità

- **Profilazione iniziale**: 50 frasi introspettive + 7 domande per creare il tuo profilo
- **Diario eventi**: Registra avvenimenti con sistema a 6 livelli (sensazione + reazione)
- **Sfide AI**: Domande scomode generate dall'intelligenza artificiale
- **Overlay di blocco**: Modalità focus che ti costringe a rispondere prima di usare il telefono
- **Riflessioni stoiche**: Citazioni di Marco Aurelio, Seneca ed Epitteto
- **Dashboard progresso**: Tracciamento del percorso 90 giorni

## Stack Tecnologico

- Flutter 3.x
- Riverpod per state management
- SQLite locale (sqflite)
- Google Gemini API (opzionale)

## Come Eseguire

### 1. Installa Flutter
```bash
# Windows
winget install Flutter

# macOS
brew install flutter

# Linux
sudo snap install flutter
```

### 2. Clona il progetto
```bash
cd 90dayman
flutter pub get
```

### 3. Eseguilo
```bash
flutter run
```

## Configurazione

### 1. Credenziali Locali

Crea il file `lib/core/config/app_config_local.dart` con le tue credenziali:

```dart
class AppConfig {
  // Neo4j Configuration
  static const String neo4jUri = 'neo4j+s://xxx.databases.neo4j.io';
  static const String neo4jUser = 'neo4j';
  static const String neo4jPassword = 'TUAPASSWORD';

  // Google Gemini AI
  static const String geminiApiKey = 'TUAGEMINIAPIKEY';

  static const String appName = 'Uomo in 90 Giorni';
  static const int onboardingQuestionCount = 50;
}
```

**Nota**: Questo file è ignorato da Git per sicurezza.

### 2. Neo4j
- Crea un account su https://neo4j.com/cloud/aura/
- Crea un database AuraDB Free
- Copia l'URI del database in app_config_local.dart

### 3. Google Gemini
- Vai su https://aistudio.google.com/app/apkey
- Crea una nuova API key
- Copiala in app_config_local.dart

## Struttura Progetto

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App widget principale
├── core/
│   ├── constants/            # Costanti app
│   ├── theme/                # Tema stoico (colori, tipografia)
│   ├── utils/                # Citazioni stoiche
│   └── widgets/              # Widget riutilizzabili
├── data/
│   ├── datasources/         # Database locale
│   └── repositories/         # Repository pattern
├── domain/
│   └── entities/            # Modelli dati
├── presentation/
│   ├── onboarding/          # Schermate iniziali
│   ├── home/                # Dashboard principale
│   ├── diary/               # Diario eventi
│   ├── challenge/           # Sfide quotidiane
│   ├── profile/             # Profilo utente
│   └── overlay/             # Schermata blocco
└── services/
    ├── ai/                  # Servizio Gemini AI
    ├── notifications/        # Gestione notifiche
    └── storage/              # Database SQLite
```

## Citazioni Stoiche Include

### Marco Aurelio
- "La vita dell'uomo è ciò che i suoi pensieri fanno di lui."
- "Hai potere sulla tua mente, non sugli eventi esterni."
- "Memento mori. Ricorda che morirai; questo è il pensiero che libera."

### Seneca
- "Non è perché le cose sono difficili che non osiamo; è perché non osiamo che sono difficili."
- "La vita breve se la usiamo bene, è sufficientemente lunga."

### Epitteto
- "Gli uomini non sono disturbati dalle cose, ma dai loro giudizi."
- "C'è solo un modo per essere felici: smettere di preoccuparsi."

## Reference Scientifiche

- Lopez & Gregory (2025). "The Development and Validation of the Stoic Attitudes and Behaviours Scale". *Cognitive Therapy and Research*
- Frontiers in Psychology (2025). "Stoicism, mindfulness, and the brain"
- Stoicism Today (2026). "Stoic Week 2025 Report"

## Piattaforme Supportate

- Android 5.0+ (API 21)
- iOS 12.0+

## Licenza

MIT License

---

*"Non è la cosa in sé a turbarci, ma il nostro giudizio su di essa."*
— Epitteto
