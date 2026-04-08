# Uomo in 90 Giorni - Project Memory

## Project Overview
- **Name**: Uomo in 90 Giorni (Mental Coach Stoico)
- **Platform**: Flutter (Android/iOS/Web)
- **Repository**: https://github.com/AdamasBuilder/90dayman

## Current Status
- ✅ Android APK funzionante
- ✅ Web buildato e zippato (`uomo90-web.zip`)
- ✅ GitHub repository configurato
- ✅ Firebase iOS configurato
- ✅ Neo4j + Gemini configurati

## Credentials (LOCAL ONLY)
File: `lib/core/config/app_config_local.dart`
- Vedere file locale per credenziali
- **NON committare su GitHub**

## Features Implemented
1. **Onboarding**: 50 domande scientifiche
2. **Diario**: Eventi con emotività e reazione
3. **AI**: Gemini per riflessioni
4. **Firebase**: Push notifications (da completare)

## 🎯 TODO Web App - Pianificato

### FISSA 1: Fix Bug UI
- [ ] Pulsante "Avanti" onboarding non funziona
- [ ] Testo va a capo su mobile

### FISSA 2: Push Notifications "stile amico"
- [ ] Firebase Web SDK
- [ ] Messaggio automatico all'apertura

### FISSA 3: Riepilogo Serale (Modal Blocco)
- [ ] Check orario (dopo 18:00)
- [ ] Schermata full-screen
- [ ] Input evento + emotività/reazione

### FISSA 4: Migliorie
- [ ] Progress bar chiara
- [ ] localStorage persistence
- [ ] PWA installabile

## Tech Stack
- Flutter 3.41.6
- Riverpod
- Neo4j (Graph)
- Gemini AI
- Firebase (Notifications)

## ⏱️ Tempo Stimato: ~3-4 ore