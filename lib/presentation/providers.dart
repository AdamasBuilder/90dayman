import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/daily_question.dart';
import '../../domain/entities/introspective_phrase.dart';
import '../../services/storage/database_service.dart';
import '../../services/ai/ai_service.dart';

final databaseServiceProvider = FutureProvider<DatabaseService>((ref) async {
  return await DatabaseService.getInstance();
});

final aiServiceProvider = FutureProvider<AIService>((ref) async {
  return await AIService.getInstance();
});

final userProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;
  final _uuid = const Uuid();

  UserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final db = await _ref.read(databaseServiceProvider.future);
      final json = await db.getUser();
      if (json == null) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.data(User.fromJson(json));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createUser(String name) async {
    try {
      final user = User(
        id: _uuid.v4(),
        name: name,
        createdAt: DateTime.now(),
        currentDay: 1,
        streakDays: 0,
        profileComplete: false,
      );
      final db = await _ref.read(databaseServiceProvider.future);
      await db.saveUser(user.toJson());
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    List<String>? painPoints,
    String? selfDescription,
    String? stressResponse,
    List<String>? coreValues,
    List<String>? avoidedThings,
    String? idealSelf90Days,
  }) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = currentUser.copyWith(
        painPoints: painPoints ?? currentUser.painPoints,
        selfDescription: selfDescription ?? currentUser.selfDescription,
        stressResponse: stressResponse ?? currentUser.stressResponse,
        coreValues: coreValues ?? currentUser.coreValues,
        avoidedThings: avoidedThings ?? currentUser.avoidedThings,
        idealSelf90Days: idealSelf90Days ?? currentUser.idealSelf90Days,
        profileComplete: true,
      );

      final db = await _ref.read(databaseServiceProvider.future);
      await db.updateUser(updatedUser.toJson());
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> incrementDay() async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = currentUser.copyWith(
        currentDay: currentUser.currentDay + 1,
        streakDays: currentUser.streakDays + 1,
      );

      final db = await _ref.read(databaseServiceProvider.future);
      await db.updateUser(updatedUser.toJson());
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadUser();
  }
}

final eventsProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<Event>>>((ref) {
  return EventsNotifier(ref);
});

class EventsNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  final Ref _ref;
  final _uuid = const Uuid();

  EventsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    final userAsync = _ref.read(userProvider);
    final user = userAsync.value;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final db = await _ref.read(databaseServiceProvider.future);
      final jsonList = await db.getEvents(user.id);
      final events = jsonList.map((e) => Event.fromJson(e)).toList();
      state = AsyncValue.data(events);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addEvent({
    required String description,
    required int feelingLevel,
    required int reactionLevel,
    List<String> tags = const [],
  }) async {
    final user = _ref.read(userProvider).value;
    if (user == null) return;

    try {
      final event = Event(
        id: _uuid.v4(),
        userId: user.id,
        timestamp: DateTime.now(),
        description: description,
        feelingLevel: feelingLevel,
        reactionLevel: reactionLevel,
        tags: tags,
      );

      final aiAsync = _ref.read(aiServiceProvider);
      final ai = aiAsync.valueOrNull;
      String? aiReflection;
      String? suggestedAction;

      if (ai != null) {
        try {
          final reflection = await ai.generateEventReflection(event, user);
          final lines = reflection.split('\n');
          for (final line in lines) {
            if (line.startsWith('RIFLESSIONE:')) {
              aiReflection = line.replaceFirst('RIFLESSIONE:', '').trim();
            } else if (line.startsWith('AZIONE:')) {
              suggestedAction = line.replaceFirst('AZIONE:', '').trim();
            }
          }
        } catch (_) {}
      }

      final finalEvent = event.copyWith(
        aiReflection: aiReflection,
        suggestedAction: suggestedAction,
      );

      final db = await _ref.read(databaseServiceProvider.future);
      await db.saveEvent(finalEvent.toJson());

      await loadEvents();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final todayEventsProvider = FutureProvider<List<Event>>((ref) async {
  final user = ref.watch(userProvider).value;
  if (user == null) return [];

  final db = await ref.watch(databaseServiceProvider.future);
  final jsonList = await db.getTodayEvents(user.id);
  return jsonList.map((e) => Event.fromJson(e)).toList();
});

final questionsProvider =
    StateNotifierProvider<QuestionsNotifier, AsyncValue<List<DailyQuestion>>>(
        (ref) {
  return QuestionsNotifier(ref);
});

class QuestionsNotifier extends StateNotifier<AsyncValue<List<DailyQuestion>>> {
  final Ref _ref;
  final _uuid = const Uuid();

  QuestionsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final user = _ref.read(userProvider).value;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final db = await _ref.read(databaseServiceProvider.future);
      final jsonList = await db.getQuestions(user.id);
      final questions = jsonList.map((e) => DailyQuestion.fromJson(e)).toList();
      state = AsyncValue.data(questions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<DailyQuestion> generateMorningQuestion() async {
    final user = _ref.read(userProvider).value!;
    final events = _ref.read(eventsProvider).value ?? [];
    final aiAsync = _ref.read(aiServiceProvider);
    final ai = aiAsync.valueOrNull;

    String question;
    if (ai != null) {
      try {
        question =
            await ai.generateMorningQuestion(user, events.take(5).toList());
      } catch (_) {
        question =
            'Cosa potresti fare oggi per avvicinarti alla persona che vuoi essere?';
      }
    } else {
      question =
          'Cosa potresti fare oggi per avvicinarti alla persona che vuoi essere?';
    }

    final dailyQuestion = DailyQuestion(
      id: _uuid.v4(),
      userId: user.id,
      date: DateTime.now(),
      question: question,
      type: QuestionType.morning,
      generatedByAI: true,
    );

    final db = await _ref.read(databaseServiceProvider.future);
    await db.saveQuestion(dailyQuestion.toJson());
    await loadQuestions();

    return dailyQuestion;
  }

  Future<DailyQuestion> generateEveningQuestion() async {
    final user = _ref.read(userProvider).value!;
    final db = await _ref.read(databaseServiceProvider.future);
    final todayJson = await db.getTodayEvents(user.id);
    final todayEvents = todayJson.map((e) => Event.fromJson(e)).toList();
    final aiAsync = _ref.read(aiServiceProvider);
    final ai = aiAsync.valueOrNull;

    String question;
    if (ai != null) {
      try {
        question = await ai.generateEveningQuestion(user, todayEvents);
      } catch (_) {
        question = 'Cosa hai imparato oggi su te stesso?';
      }
    } else {
      question = 'Cosa hai imparato oggi su te stesso?';
    }

    final dailyQuestion = DailyQuestion(
      id: _uuid.v4(),
      userId: user.id,
      date: DateTime.now(),
      question: question,
      type: QuestionType.evening,
      generatedByAI: true,
    );

    await db.saveQuestion(dailyQuestion.toJson());
    await loadQuestions();

    return dailyQuestion;
  }

  Future<DailyQuestion> generateOnDemandChallenge() async {
    final user = _ref.read(userProvider).value!;
    final aiAsync = _ref.read(aiServiceProvider);
    final ai = aiAsync.valueOrNull;

    String question;
    if (ai != null) {
      try {
        question = await ai.generateOnDemandChallenge(user);
      } catch (_) {
        question = 'Fai qualcosa che ti spaventa oggi.';
      }
    } else {
      question = 'Fai qualcosa che ti spaventa oggi.';
    }

    final dailyQuestion = DailyQuestion(
      id: _uuid.v4(),
      userId: user.id,
      date: DateTime.now(),
      question: question,
      type: QuestionType.onDemand,
      generatedByAI: true,
    );

    final db = await _ref.read(databaseServiceProvider.future);
    await db.saveQuestion(dailyQuestion.toJson());
    await loadQuestions();

    return dailyQuestion;
  }

  Future<void> answerQuestion(String questionId, String answer) async {
    final questions = state.value ?? [];
    final questionIndex = questions.indexWhere((q) => q.id == questionId);
    if (questionIndex == -1) return;

    final updatedQuestion = questions[questionIndex].copyWith(
      answer: answer,
      answeredAt: DateTime.now(),
    );

    final db = await _ref.read(databaseServiceProvider.future);
    await db.updateQuestion(updatedQuestion.toJson());
    await loadQuestions();
  }

  Future<DailyQuestion?> getTodaysQuestion(QuestionType type) async {
    final user = _ref.read(userProvider).value;
    if (user == null) return null;

    final db = await _ref.read(databaseServiceProvider.future);
    final json = await db.getTodaysQuestion(user.id, type.name);
    if (json == null) return null;
    return DailyQuestion.fromJson(json);
  }
}

final phrasesProvider = FutureProvider<List<IntrospectivePhrase>>((ref) async {
  final db = await ref.watch(databaseServiceProvider.future);
  final jsonList = await db.getPhrases();
  return jsonList.map((e) => IntrospectivePhrase.fromJson(e)).toList();
});

final savedPhrasesProvider =
    FutureProvider<List<IntrospectivePhrase>>((ref) async {
  final phrases = await ref.watch(phrasesProvider.future);
  return phrases.where((p) => p.isSaved).toList();
});

final overlayStateProvider = StateProvider<bool>((ref) => false);
final overlayQuestionProvider = StateProvider<DailyQuestion?>((ref) => null);
final postponeCountProvider = StateProvider<int>((ref) => 0);
