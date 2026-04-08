# Uomo in 90 Giorni - Project Memory

## Project Overview
- **Name**: Uomo in 90 Giorni (Mental Coach Stoico)
- **Platform**: Flutter (Android/iOS/Web)
- **Repository**: https://github.com/AdamasBuilder/90dayman

## Current Status
- ✅ Android APK funzionante
- ✅ Web buildato e zippato (`uomo90-web.zip`)
- ✅ GitHub repository configurato
- ✅ Neo4j configurato
- ✅ Gemini AI configurato

## Credentials (LOCAL ONLY - NOT ON GITHUB)
File: `lib/core/config/app_config_local.dart`
- Neo4j URI: `neo4j+s://eee9a2de.databases.neo4j.io`
- Neo4j User: `neo4j`
- Neo4j Password: `GuIbM7ZZNRnkEeoCdvlyJp_LohG2A9Vl579uPXWQXmQ` (DA CAMBIARE!)
- Gemini API: `AIzaSyDI7myuqIQAl9t1fQ0q4GYy2SUuHz39mrU`

## Security Notes
- File `app_config_local.dart` è in `.gitignore`
- NON committare MAI credenziali
- Password Neo4j precedente era esposta - UTENTE DEVE CAMBIARLA

## Features Implemented
1. **Onboarding**: 50 domande scientifiche (Stoic Attitudes, Grit, DERS, Big Five, PSS)
2. **Diario**: Eventi con emotività (1-6) e reazione (1-6)
3. **AI**: Gemini per riflessioni e messaggi
4. **Neo4j**: Graph-RAG per pattern comportamentali
5. **Push Notifications**: Placeholder (richiede Firebase per implementazione reale)

## Next Steps (when resuming)
1. Testare web su Hostinger
2. Implementare push notifications reali con Firebase
3. Build iOS (richiede Mac o Codemagic)
4. Migliorare UI/UX

## Key Files
- `lib/services/ai/ai_service.dart` - AI Gemini
- `lib/services/storage/neo4j_service.dart` - Neo4j
- `lib/services/notifications/notification_service.dart` - Notifications
- `lib/presentation/onboarding/onboarding_screen.dart` - 50 domande
- `lib/presentation/home/home_screen.dart` - Main screen
- `lib/core/config/app_config_local.dart` - Credenziali locali

## Commands
```bash
# Build Android
flutter build apk --debug

# Build Web
flutter build web --release

# Run on emulator
flutter run -d emulator-5554
```

## Tech Stack
- Flutter 3.41.6
- Riverpod (state management)
- dart_neo4j (Graph database)
- google_generative_ai (Gemini)
- SharedPreferences (local storage)