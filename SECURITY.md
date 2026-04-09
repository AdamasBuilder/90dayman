# Configurazione Sicurezza - UOMO 90 GIORNI

## ⚠️ IMPORTANTE: Credenziali mai committare su GitHub

### File da configurare localmente

#### 1. iOS: `ios/Runner/GoogleService-Info.plist`
Scarica questo file dalla Firebase Console:
1. Vai su https://console.firebase.google.com
2. Seleziona il progetto
3. Vai su Project Settings > Your apps > iOS app
4. Scarica GoogleService-Info.plist
5. Sostituisci il file placeholder

#### 2. Android: `android/app/google-services.json`
Scarica questo file dalla Firebase Console:
1. Vai su https://console.firebase.google.com
2. Seleziona il progetto
3. Vai su Project Settings > Your apps > Android app
4. Aggiungi il package name: `com.stoic.uomo90`
5. Scarica google-services.json
6. Sostituisci il file placeholder

#### 3. API Keys (Environment Variables)

Per lo sviluppo locale, crea un file `.env.local` nella root del progetto:

```
GEMINI_API_KEY=la_tua_chiave_gemini
NEO4J_URI=neo4j+s://xxx.databases.neo4j.io
NEO4J_PASSWORD=la_tua_password_neo4j
```

### Configurazione Codemagic

In Codemagic, vai su Environment Variables e aggiungi:

| Name | Description |
|------|-------------|
| GEMINI_API_KEY | API Key Google Gemini |
| NEO4J_URI | URI del database Neo4j |
| NEO4J_PASSWORD | Password Neo4j |
| FIREBASE_API_KEY | Firebase Web API Key |
| FIREBASE_GCM_SENDER_ID | Firebase Sender ID |
| FIREBASE_GOOGLE_APP_ID | Firebase App ID |
| FIREBASE_PROJECT_ID | Firebase Project ID |
| FIREBASE_STORAGE_BUCKET | Firebase Storage Bucket |

### Rotazione Credenziali

Se credenziali sono state esposte:
1. Revoca immediatamente le chiavi dalla console
2. Genera nuove chiavi
3. Aggiorna Codemagic Environment Variables
4. NOTA: Neo4j Aura richiede la creazione di un nuovo database se la password è compromessa
