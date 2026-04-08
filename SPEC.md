# SPEC.md - Mental Coach Stoico: Uomo in 90 Giorni

## 1. Concept & Vision

Un mentore digitale stoico che guida l'uomo moderno verso la padronanza di sé attraverso la filosofia di Marco Aurelio, Seneca e Epitteto. L'app non è un semplice diario, ma un coach implacabile che raccoglie dati sull'utente, lo sfida con domande scomode e lo costringe al confronto con la propria realtà. L'esperienza è austera, meditativa, quasi militare - come un antico romano che allena la propria mente.

**Filosofia centrale**: "Non è la cosa in sé a turbarci, ma il nostro giudizio su di essa" - Epitteto. L'app insegna a separare i fatti dalle interpretazioni, a controllare le reazioni, a costruire resilienza attraverso la consapevolezza.

---

## 2. Design Language

### Aesthetic Direction
**Minimalismo Romano Antico** - pietra, bronzo, papiro. Riferimento visivo: musei archeologici romani con superfici testurizzate, iscrizioni su pietra, bronzo ossidato. Nessuna decorazione superflua, solo funzione e significato.

### Color Palette
```
Primary:        #8B7355 (Bronzo antico)
Secondary:      #C4A77D (Sabbia del Colosseo)
Accent:         #D4AF37 (Oro Romano)
Background:     #1A1814 (Nero Ossidiana)
Surface:        #2D2A26 (Grigio Pietra)
Text Primary:   #E8E0D5 (Papiro chiaro)
Text Secondary: #9A9285 (Grigio Lapide)
Success:        #6B8E6B (Ulivo)
Warning:        #CD853F (Terra di Siena)
Error:          #8B4513 (Terracotta)
```

### Typography
- **Headlines**: Cinzel (Google Fonts) - epigrafi romane
- **Body**: Inter (Google Fonts) - leggibilità moderna con serifs decorativi opzionali
- **Quotes**: Cormorant Garamond Italic - citazioni filosofiche

### Spatial System
- Base unit: 8px
- Spacing scale: 8, 16, 24, 32, 48, 64, 96
- Border radius: 4px (squareness romano)
- Card elevation: 0 (flat, come incisioni su pietra)

### Motion Philosophy
- Transizioni lente e dignitose (400-600ms)
- Easing: ease-in-out per riflettere la meditazione
- Nessuna animazione frivola
- Animazioni di respirazione per stati di attesa

---

## 3. Layout & Structure

### Architettura Schermi

```
├── ONBOARDING (solo prima volta)
│   ├── Welcome Screen
│   ├── 50 Frasi Introspettive (swiper)
│   ├── Profilazione Iniziale (7 domande)
│   └── Impostazione Obiettivi
│
├── MAIN APP
│   ├── Overlay di Blocco (modalità focus)
│   ├── Dashboard (home)
│   │   ├── Saluto stoico del momento
│   │   ├── Progresso 90 giorni
│   │   ├── Evento del giorno
│   │   └── Quote stoico random
│   │
│   ├── Diario
│   │   ├── Lista eventi
│   │   ├── Nuovo evento (form)
│   │   └── Dettaglio evento
│   │
│   ├── Sfida Giornaliera
│   │   ├── Domanda scomoda AI
│   │   ├── Cronologia domande
│   │   └── Statistiche risposta
│   │
│   ├── Profilo
│   │   ├── Radar emozioni
│   │   ├── Pattern comportamentali
│   │   ├── Evoluzione 90 giorni
│   │   └── Impostazioni
```

### Responsive Strategy
- Mobile-first (320px - 428px)
- Tablet: layout a due colonne dove appropriato
- Massima larghezza contenuto: 600px

---

## 4. Features & Interactions

### 4.1 Profilazione Iniziale (Onboarding)

**50 Frasi Introspettive** - Mostrate una alla volta, swipe per continuare:
- Frasi basate su ricerche scientifiche (Philips 2025, Frontiers in Psychology)
- 5 categorie: Autoconsapevolezza, Controllo Emotivo, Resilienza, Valori, Azione
- L'utente può salvare frasi preferite

**7 Domande di Profilazione**:
1. "Cosa ti porta qui oggi? Qual è il tuo punto di sofferenza?"
2. "Descrivi te stesso con tre aggettivi che altri potrebbero non vedere"
3. "Qual è l'evento recente che ha scatenato la tua reazione più intensa?"
4. "Come rispondi normalmente allo stress? (fuga, attacco, paralisi, riflessione)"
5. "Quali sono i tuoi tre valori più importanti nella vita?"
6. "Cosa eviti di fare o affrontare che sai di dover affrontare?"
7. "Definisci il 'te stesso ideale' tra 90 giorni"

### 4.2 Sistema di Eventi

**Campo di inserimento libero**:
- textarea per descrivere avvenimento
- Selezione orario/data (default: ora corrente)
- Tag automatici (lavoro, relazioni, salute, finanze, crescita)

**Sistema a 6 Livelli**:

| Livello | Sensazione | Reazione |
|---------|------------|----------|
| 1 | Tranquillità | Accettazione totale |
| 2 | Discomfort lieve | Riconoscimento |
| 3 | Frustrazione | Tentativo di adattamento |
| 4 | Rabbia/Ansia | Reazione impulsiva |
| 5 | Angoscia | Paralisi o evitamento |
| 6 | Crisi | Abbattimento totale |

**Interazioni**:
- Tap su slider per selezionare livello
- Vibrazione feedback a ogni livello
- Colore che cambia progressivamente
- Suggerimento contestuale basato sul livello

### 4.3 Motore AI (Gemini)

**Generazione Domande** basata su:
- Profilo utente raccolto
- Eventi recenti inseriti
- Livelli emotivi registrati
- Pattern comportamentali identificati
- Momento della giornata

**Tipi di domande generate**:
- Introspettive ("Cosa ha rivelato questa reazione su di te?")
- Di sfida ("Se un amico ti descrivesse questa situazione, cosa gli diresti?")
- Pratiche ("Quale azione specifica puoi fare oggi per affrontare questo?")
- Stoiche ("Marco Aurelio affrontava situazioni simili. Come?")

### 4.4 Sistema di Blocco Telefono

**Overlay Minima**:
- Schermata fullscreen con domanda del giorno
- Nessun modo di chiudere senza rispondere
- Tre opzioni: Rispondi ora, Rimanda 15min, Rimanda 1h
- Dopo 3 rimandi: prompt obbligatorio
- Sfondo scuro, testo centrato, respiro visivo

**Trigger**:
- Mattina: 7:00-8:00 (Morning Check-in)
- Sera: 21:00-22:00 (Evening Reflection)
- On-demand: "Inizia sessione di riflessione"

### 4.5 Dashboard

**Saluto basato su momento**:
- Mattina: "Il giorno è nuovo. Sei pronto a combattere la battaglia più importante?"
- Mezzogiorno: "A metà strada. Come procede la tua disciplina?"
- Sera: "La luce cala. Quale uomo sei stato oggi?"
- Notte: "Nel silenzio, rifletti sulla tua giornata"

**Progress Bar 90 Giorni**:
- Barra verticale a sinistra
- Giorni completati in bronzo
- Giorno corrente pulsante
- Obiettivo finale visibile

---

## 5. Component Inventory

### 5.1 StoicQuoteCard
- **Default**: Sfondo Surface, bordo Accent sottile, testo Quote in Cormorant
- **Saved**: Icona libro aperto in oro
- **Loading**: Shimmer effect

### 5.2 EmotionSlider (6 livelli)
- **Default**: Slider orizzontale con 6 tacche
- **Active**: Tacca selezionata ingrandita, colore pieno
- **Filled**: Tutte le tacche compilate fino al livello selezionato
- **Disabled**: Grigio, non interattivo

### 5.3 EventCard
- **Default**: Data + preview testo + livello emotivo come badge colorato
- **Expanded**: Full text + tag + azioni
- **Empty**: Messaggio "Nessun evento registrato oggi"

### 5.4 QuestionCard
- **Unanswered**: Background Warning, testo prominence
- **Answered**: Background Success, checkmark
- **Pending**: Background Primary, count-down timer

### 5.5 BlockingOverlay
- **Active**: Fullscreen, background 95% opacity
- **Minimized**: Bottone floating "Continua riflessione"
- **Completed**: Transizione fade out

### 5.6 ProfileProgress
- **Radar chart**: 5 assi (Consapevolezza, Controllo, Resilienza, Valori, Azione)
- **Bar chart**: Evoluzione giornaliera livelli emotivi
- **Streak counter**: Giorni consecutivi con check-in

---

## 6. Technical Approach

### Stack Tecnologico
- **Framework**: Flutter 3.x (ultima versione stabile)
- **AI**: Google Gemini API (gemini-2.0-flash)
- **Storage**: SQLite locale (sqflite + drift)
- **State**: Riverpod (flutter_riverpod)
- **Architecture**: Clean Architecture (presentation/domain/data layers)

### Struttura Progetto
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── onboarding/
│   ├── home/
│   ├── diary/
│   ├── challenge/
│   ├── profile/
│   └── overlay/
└── services/
    ├── ai/
    ├── notifications/
    └── storage/
```

### Data Models

**User**:
- id, name, createdAt
- painPoints[], selfDescription, stressResponse
- coreValues[], avoidedThings, idealSelf90Days
- currentDay, streakDays, profileComplete

**Event**:
- id, userId, timestamp
- description, tags[]
- feelingLevel (1-6), reactionLevel (1-6)
- aiReflection?, suggestedAction?

**DailyQuestion**:
- id, userId, date
- question, type (morning/evening/on-demand)
- answer?, answeredAt?, generatedByAI

**IntrospectivePhrase**:
- id, text, category, isSaved

### API Gemini Integration

**Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent`

**Prompt Templates**:

Per domande mattutine:
```
Sei Marco Aurelio. L'utente sta iniziando il giorno [X] di 90.
Profilo: [profilo utente]
Eventi recenti: [ultimi eventi]
Genera UNA domanda scomoda che lo sfidi a crescere.
Formato: solo la domanda, nient'altro.
```

Per domande serali:
```
Sei un terapeuta stoico. L'utente ha vissuto oggi: [eventi]
Livelli emotivi medi: [livelli]
Genera UNA domanda di riflessione profonda.
Formato: solo la domanda.
```

### Storage Schema (SQLite)

```sql
CREATE TABLE users (id TEXT PRIMARY KEY, name TEXT, ...);
CREATE TABLE events (id TEXT PRIMARY KEY, user_id TEXT, ...);
CREATE TABLE daily_questions (id TEXT PRIMARY KEY, user_id TEXT, ...);
CREATE TABLE phrases (id TEXT PRIMARY KEY, text TEXT, category TEXT, is_saved INTEGER);
```

---

## 7. 50 Frasi Introspettive

### Categoria: Autoconsapevolezza (1-10)
1. "Chi sei quando nessuno ti sta guardando?"
2. "Quale emozione eviti di sentire più frequentemente?"
3. "Le tue azioni corrispondono ai tuoi valori dichiarati?"
4. "Cosa diresti a te stesso di 10 anni fa?"
5. "Qual è la bugia più grande che ti racconti?"
6. "Dove va la tua mente quando sei completamente libero?"
7. "Hai paura del successo o del fallimento?"
8. "Quale versione di te stai cercando di impressionare?"
9. "Cosa otterresti se smettessi di cercare l'approvazione degli altri?"
10. "Sei disposto a soffrire per ciò che dici di volere?"

### Categoria: Controllo Emotivo (11-20)
11. "Chi controlla le tue emozioni: tu o le circostanze?"
12. "Reagisci o rispondi agli eventi?"
13. "Cosa accadrebbe se accettassi fully ciò che non puoi cambiare?"
14. "Il tuo disagio viene da dentro o da fuori?"
15. "Stai resistendo a qualcosa che deve accadere?"
16. "Come saresti se smettessi di interpretare un ruolo?"
17. "La tua rabbia protegge o ferisce te stesso?"
18. "Qual è la differenza tra essere irritato ed essere arrabbiato?"
19. "Stai evitando un confronto necessario?"
20. "Cosa può realmente ferirti in questa situazione?"

### Categoria: Resilienza (21-30)
21. "Cosa ti ha insegnato l'ultimo fallimento?"
22. "Stai usando il passato come prigione o come scuola?"
23. "Se tutto andasse secondo i piani, saresti davvero felice?"
24. "Cosa temi di più: il cambiamento o la stagnazione?"
25. "Hai il coraggio di ricominciare?"
26. "La tua comfort zone ti sta confortando o imprigionando?"
27. "Cosa significa per te essere forte?"
28. "Come risponderesti a questa situazione tra 5 anni?"
29. "Stai crescendo o solo mantenendo?"
30. "La vita ti sta piegando o forgiando?"

### Categoria: Valori (31-40)
31. "Se avessi un anno di vita, cosa cambieresti?"
32. "I tuoi soldi comprano la tua felicità o la tua distrazione?"
33. "Stai investendo in relazioni o in possessi?"
34. "Chi hai deluso per compiacere qualcun altro?"
35. "La tua carriera definisce il tuo valore?"
36. "Cosa diresti se non potessi più parlare?"
37. "Stai vivendo secondo le tue priorità o quelle degli altri?"
38. "Qual è il prezzo della tua pace?"
39. "Le tue relazioni ti alzano o abbassano?"
40. "Stai costruendo un'eredità o solo un curriculum?"

### Categoria: Azione (41-50)
41. "Cosa hai fatto oggi che ti ha avvicinato al tuo obiettivo?"
42. "Stai pianificando o stai procrastinando?"
43. "Cosa eviti perché è difficile?"
44. "Il tuo comportamento di oggi riflette chi vuoi essere?"
45. "Hai preso una decisione difficile ultimamente?"
46. "Stai crescendo nella direzione giusta?"
47. "Qual è l'unica azione che cambierebbe tutto?"
48. "Cosa continueresti a fare anche senza ricevere nulla in cambio?"
49. "Stai agendo per paura o per scelta?"
50. "Oggi hai fatto qualcosa di cui essere orgoglioso, anche solo piccolo?"

---

## 8. References Scientifiche

1. **Lopez & Gregory (2025)**. "The Development and Validation of the Stoic Attitudes and Behaviours Scale". *Cognitive Therapy and Research*. Springer Nature.

2. **Frontiers in Psychology (2025)**. "Stoicism, mindfulness, and the brain: the empirical foundations of second-order desires". Frontiers Media SA.

3. **Stoicism Today (2026)**. "Stoic Week 2025 Report: Well-being, Vitality, Happiness".

4. **PMC (2024)**. "Time to Form a Habit: A Systematic Review and Meta-Analysis". Healthcare journal.

5. **Psychology Today (2025)**. "Lessons From Marcus Aurelius for the Modern World".

6. **EL PAÍS (2024)**. "The science of Stoicism: Does it really improve mental health?".

---

## 9. Implementazione Gemelli Digitali Stoici

### Marco Aurelio
- Frasi quotidiane dai "Meditations"
- Riflessioni sul dovere e la responsabilità
- Promemoria sulla mortalità (memento mori)

### Seneca
- Lettere a Lucilio come base per le domande
- Focus sulla virtù e la saggezza
- Esercizi sulla brevità della vita

### Epitteto
- Il concetto di "dioikesis" - discernimento
- Distinzione tra ciò che è in nostro potere e ciò che non lo è
- Enchiridion come guida pratica
