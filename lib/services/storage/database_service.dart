import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static SharedPreferences? _prefs;
  static bool _initialized = false;

  DatabaseService._();

  static Future<DatabaseService> getInstance() async {
    if (_instance == null) {
      _instance = DatabaseService._();
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
    return _instance!;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await getInstance();
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    await _ensureInitialized();
    final jsonString = _prefs?.getString('user');
    if (jsonString == null) return null;
    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _ensureInitialized();
    await _prefs?.setString('user', jsonEncode(user));
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    await saveUser(user);
  }

  Future<List<Map<String, dynamic>>> getEvents(String userId) async {
    await _ensureInitialized();
    final jsonString = _prefs?.getString('events_$userId');
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getTodayEvents(String userId) async {
    final events = await getEvents(userId);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return events.where((e) {
      final timestamp = DateTime.parse(e['timestamp']);
      return timestamp.isAfter(startOfDay);
    }).toList();
  }

  Future<void> saveEvent(Map<String, dynamic> event) async {
    await _ensureInitialized();
    final userId = event['userId'];
    final events = await getEvents(userId);
    events.insert(0, event);
    await _prefs?.setString('events_$userId', jsonEncode(events));
  }

  Future<List<Map<String, dynamic>>> getQuestions(String userId) async {
    await _ensureInitialized();
    final jsonString = _prefs?.getString('questions_$userId');
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> getTodaysQuestion(
      String userId, String type) async {
    final questions = await getQuestions(userId);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    for (final q in questions) {
      final date = DateTime.parse(q['date']);
      if (q['type'] == type &&
          date.isAfter(startOfDay) &&
          date.isBefore(endOfDay)) {
        return q;
      }
    }
    return null;
  }

  Future<void> saveQuestion(Map<String, dynamic> question) async {
    await _ensureInitialized();
    final userId = question['userId'];
    final questions = await getQuestions(userId);
    questions.insert(0, question);
    await _prefs?.setString('questions_$userId', jsonEncode(questions));
  }

  Future<void> updateQuestion(Map<String, dynamic> question) async {
    await _ensureInitialized();
    final userId = question['userId'];
    final questions = await getQuestions(userId);
    final index = questions.indexWhere((q) => q['id'] == question['id']);
    if (index != -1) {
      questions[index] = question;
      await _prefs?.setString('questions_$userId', jsonEncode(questions));
    }
  }

  Future<List<Map<String, dynamic>>> getPhrases() async {
    await _ensureInitialized();
    final saved = _prefs?.getString('saved_phrases');
    Set<String> savedIds = {};
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      savedIds = decoded.map((e) => e['id'] as String).toSet();
    }

    return _getInitialPhrases().asMap().entries.map((e) {
      return {
        'id': 'phrase_${e.key}',
        'text': e.value['text'],
        'category': e.value['category'],
        'isSaved': savedIds.contains('phrase_${e.key}') ? 1 : 0,
      };
    }).toList();
  }

  Future<void> togglePhraseSaved(String phraseId, bool isSaved) async {
    await _ensureInitialized();
    final saved = _prefs?.getString('saved_phrases');
    List<Map<String, String>> savedList = [];
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      savedList = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    if (isSaved) {
      savedList.add({'id': phraseId});
    } else {
      savedList.removeWhere((p) => p['id'] == phraseId);
    }
    await _prefs?.setString('saved_phrases', jsonEncode(savedList));
  }

  Future<void> saveOnboardingResponse(String questionId, int response) async {
    await _ensureInitialized();
    final responses = _prefs?.getString('onboarding_responses');
    Map<String, int> responseMap = {};
    if (responses != null) {
      final Map<String, dynamic> decoded = jsonDecode(responses);
      responseMap = decoded.map((k, v) => MapEntry(k, v as int));
    }
    responseMap[questionId] = response;
    await _prefs?.setString('onboarding_responses', jsonEncode(responseMap));
  }

  Future<Map<String, int>> getOnboardingResponses() async {
    await _ensureInitialized();
    final responses = _prefs?.getString('onboarding_responses');
    if (responses == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(responses);
    return decoded.map((k, v) => MapEntry(k, v as int));
  }

  List<Map<String, dynamic>> _getInitialPhrases() {
    return [
      // STOIC ATTITUDES SCALE (Modern Stoicism) - 12 items
      {
        'text':
            'Ritengo che accettare le cose così come sono mi aiuti a vivere meglio',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale (Modern Stoicism)'
      },
      {
        'text':
            'Quando qualcosa va storto, mi dico che sarebbe potuto andare peggio',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text':
            'Cerco di accettare che ci saranno sempre cose fuori dal mio controllo',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text':
            'Credo che cercare di controllare ciò che non posso controllare crei solo frustrazione',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text':
            'Quando provo emozioni negative, cerco di osservarle senza farmi travolgere',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text': 'Ritengo che i problemi siano opportunità per crescere',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text':
            'Cerco di vivere nel momento presente piuttosto che preoccuparmi del futuro',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text': 'Ritengo che le avversità siano parte naturale della vita',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text': 'Mi sforzo di accettare con calma ciò che non posso cambiare',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text': 'Credo che agire secondo virtù sia più importante del successo',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text':
            'Cerco di non farmi influenzare troppo dalle opinioni degli altri',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      {
        'text':
            'Ritengo che la saggezza stia nel distinguere ciò che posso e non posso controllare',
        'category': 'stoicAttitude',
        'source': 'Stoic Attitudes Scale'
      },
      // GRIT SCALE (Angela Duckworth) - 10 items
      {
        'text':
            'Nuove idee e progetti mi capita spesso di abbandonare per others',
        'category': 'grit',
        'source': 'Grit Scale (Duckworth)'
      },
      {
        'text':
            'Ho difficulty mantenere la concentrazione su obiettivi a lungo termine',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      {
        'text': 'I miei interessi cambiano di frequente',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      {
        'text': 'Quando mi impegno in qualcosa, la porto sempre a termine',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      {
        'text': 'Superare le difficoltà mi rende più forte',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      {
        'text': 'Non mi arrendo facilmente di fronte agli ostacoli',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      {
        'text': 'Ho un obiettivo principale a cui sto lavorando',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      {
        'text': 'So cosa voglio raggiungere nella vita',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      {
        'text': 'Dedico tempo e sforzo costante ai miei obiettivi',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      {
        'text':
            'Riesco a mantenere la motivazione anche quando incontro ostacoli',
        'category': 'grit',
        'source': 'Grit Scale'
      },
      // DERS - Difficulties in Emotion Regulation Scale - 10 items
      {
        'text': 'Mi risulta difficile controllare le mie emozioni intense',
        'category': 'emotionRegulation',
        'source': 'DERS (Gratz & Roemer)'
      },
      {
        'text': 'Quando sono arrabbiato/a, ho difficulty a pensare chiaramente',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      {
        'text': 'Mi capita di sentire emozioni che non capisco',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      {
        'text': 'Ho difficulty a calmarmi dopo un momento di forte stress',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      {
        'text': 'Quando sono triste, faccio fatica a pensare a altro',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      {
        'text': 'Le mie emozioni spesso mi sopraffanno',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      {
        'text': 'Ho difficulty a tollerare sentimenti dolorosi',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      {
        'text':
            'Mi capita di agire in modi che poi mi pentisco quando provo emozioni forti',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      {
        'text': 'Faccio fatica a comprendere cosa sto sentendo',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      {
        'text': 'Mi capita di perdere il controllo quando provo emozioni forti',
        'category': 'emotionRegulation',
        'source': 'DERS'
      },
      // BIG FIVE (sintetico) - 10 items
      {
        'text':
            'Mi considero una persona socievole e aperta alle nuove esperienze',
        'category': 'personality',
        'source': 'BFI-2 (John & Soto)'
      },
      {
        'text': 'Essere affidabile e responsabile è importante per me',
        'category': 'personality',
        'source': 'BFI-2'
      },
      {
        'text': 'Mi capita spesso di sentirmi ansioso/a o preoccupato/a',
        'category': 'personality',
        'source': 'BFI-2'
      },
      {
        'text': 'Riesco facilmente a farmi nuovi amici',
        'category': 'personality',
        'source': 'BFI-2'
      },
      {
        'text': 'Cerco sempre nuove sfide e preferisco la varietà alla routine',
        'category': 'personality',
        'source': 'BFI-2'
      },
      {
        'text': 'Mi capita di mettere le esigenze degli altri avanti alle mie',
        'category': 'personality',
        'source': 'BFI-2'
      },
      {
        'text': 'Mantengo la calma anche sotto pressione',
        'category': 'personality',
        'source': 'BFI-2'
      },
      {
        'text': 'Mi piace avere il controllo sulle situazioni',
        'category': 'personality',
        'source': 'BFI-2'
      },
      {
        'text': 'Mi sento spesso insicuro/a su me stesso/a',
        'category': 'personality',
        'source': 'BFI-2'
      },
      {
        'text': 'Riesco a farmi valere quando necessario',
        'category': 'personality',
        'source': 'BFI-2'
      },
      // PSS-10 (Perceived Stress Scale) - 8 items
      {
        'text': 'Mi sono sentito/a nervoso/a o stressato/a spesso ultimamente',
        'category': 'stress',
        'source': 'PSS-10 (Cohen)'
      },
      {
        'text': 'Ho avuto difficulty a sentirmi calmo/a di recente',
        'category': 'stress',
        'source': 'PSS-10'
      },
      {
        'text': 'Mi sono sentito/a sopraffatto/a dalle responsabilità',
        'category': 'stress',
        'source': 'PSS-10'
      },
      {
        'text':
            'Ultimamente ho avuto la sensazione che le cose non andassero come volevo',
        'category': 'stress',
        'source': 'PSS-10'
      },
      {
        'text':
            'Mi sono preoccupato/a per questioni che normalmente non mi preoccupano',
        'category': 'stress',
        'source': 'PSS-10'
      },
      {
        'text':
            'Ho sentito di non avere Everything under control nella mia vita',
        'category': 'stress',
        'source': 'PSS-10'
      },
      {
        'text': 'Mi è stato difficile godermi le cose come prima',
        'category': 'stress',
        'source': 'PSS-10'
      },
      {
        'text': 'Ho avuto difficulty a concentrarmi su quello che facevo',
        'category': 'stress',
        'source': 'PSS-10'
      },
    ];
  }
}
