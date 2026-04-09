import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/event.dart';
import '../../core/config/app_config.dart';
import 'ai_fallback_generator.dart';

class AIService {
  // Load from local config (not committed to git)
  static String get _apiKey => AppConfig.geminiApiKeyFinal;
  static AIService? _instance;
  GenerativeModel? _model;
  bool _initialized = false;

  AIService._();

  static Future<AIService> getInstance() async {
    if (_instance == null) {
      _instance = AIService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    if (_initialized) return;
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 512,
      ),
    );
    _initialized = true;
  }

  Future<void> ensureInitialized() async {
    if (!_initialized) await _init();
  }

  Future<String> generateMorningQuestion(
      User user, List<Event> recentEvents) async {
    if (_initialized && _model != null) {
      try {
        return await _callGemini(_buildMorningPrompt(user, recentEvents));
      } catch (e) {
        return AIQuestionGenerator.generateMorningQuestion(user, recentEvents);
      }
    }
    return AIQuestionGenerator.generateMorningQuestion(user, recentEvents);
  }

  Future<String> generateEveningQuestion(
      User user, List<Event> todayEvents) async {
    if (_initialized && _model != null) {
      try {
        return await _callGemini(_buildEveningPrompt(user, todayEvents));
      } catch (e) {
        return AIQuestionGenerator.generateEveningQuestion(user, todayEvents);
      }
    }
    return AIQuestionGenerator.generateEveningQuestion(user, todayEvents);
  }

  Future<String> generateOnDemandChallenge(User user) async {
    if (_initialized && _model != null) {
      try {
        return await _callGemini(_buildChallengePrompt(user));
      } catch (e) {
        return AIQuestionGenerator.generateOnDemandChallenge(user);
      }
    }
    return AIQuestionGenerator.generateOnDemandChallenge(user);
  }

  Future<String> generateEventReflection(Event event, User user) async {
    if (_initialized && _model != null) {
      try {
        return await _callGemini(_buildReflectionPrompt(event, user));
      } catch (e) {
        return AIQuestionGenerator.generateEventReflection(event);
      }
    }
    return AIQuestionGenerator.generateEventReflection(event);
  }

  Future<String> analyzeOnboardingResponses(Map<String, int> responses) async {
    if (!_initialized || _model == null) {
      return 'Analisi completata. Continua il tuo percorso stoico.';
    }

    final prompt = '''
Sei "UOMO" - un coach stoico. Analizza le risposte dell'utente e fornisci un profilo sintetico.

Risposte: $responses

Rispondi con:
1. Punti di forza (2)
2. Aree da migliorare (2)
3. Una raccomandazione per iniziare il percorso

Sii breve e diretto. Max 3 frasi.
''';

    try {
      return await _callGemini(prompt);
    } catch (e) {
      return 'Oggi inizia il resto della tua vita. Scegli chi vuoi essere.';
    }
  }

  Future<String> generateDailyMessage(User user) async {
    if (!_initialized || _model == null) {
      return AIQuestionGenerator.getRandomQuote();
    }

    final prompt = '''
Sei "UOMO" - un coach stoico che parla come un amico via WhatsApp.

Profilo:
- Giorno: ${user.currentDay} di 90
- Self-descrizione: ${user.selfDescription ?? 'Non definita'}

Genera UN messaggio breve (max 2 frasi) motivante e personale.
Nessuna emoji. Parla come un uomo vero.
''';

    try {
      return await _callGemini(prompt);
    } catch (e) {
      return AIQuestionGenerator.getRandomQuote();
    }
  }

  String _buildMorningPrompt(User user, List<Event> recentEvents) {
    final eventsSummary = recentEvents.isEmpty
        ? 'Nessun evento recente'
        : recentEvents.take(3).map((e) => '- ${e.description}').join('\n');

    return '''
Sei Marco Aurelio, filosofo stoico romano. L'utente "${user.name}" sta iniziando il giorno ${user.currentDay} di 90.

Eventi recenti:
$eventsSummary

Genera UNA domanda scomoda e profonda ispirata allo stoicismo. Solo la domanda.
''';
  }

  String _buildEveningPrompt(User user, List<Event> todayEvents) {
    final eventsSummary = todayEvents.isEmpty
        ? 'Nessun evento'
        : todayEvents.map((e) => '- ${e.description}').join('\n');

    return '''
Sei Seneca, filosofo stoico. L'utente "${user.name}" sta finendo il giorno ${user.currentDay}.

Eventi di oggi:
$eventsSummary

Genera UNA domanda di riflessione per la sera. Solo la domanda.
''';
  }

  String _buildChallengePrompt(User user) {
    return '''
Sei Epitteto, filosofo stoico. L'utente "${user.name}" richiede una sfida.

Genera UNA sfida scomoda e specifica. Solo la sfida.
''';
  }

  String _buildReflectionPrompt(Event event, User user) {
    return '''
Sei un terapeuta stoico. Analizza brevemente questo evento:

Evento: ${event.description}
Livello sensazione: ${event.feelingLevel}
Livello reazione: ${event.reactionLevel}

Formato:
RIFLESSIONE: [breve riflessione]
AZIONE: [un'azione specifica]
''';
  }

  Future<String> _callGemini(String prompt) async {
    final content = Content.text(prompt);
    final response = await _model!.generateContent([content]);
    return response.text ?? '';
  }
}
