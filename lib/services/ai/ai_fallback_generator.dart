import 'dart:math';
import '../../domain/entities/user.dart';
import '../../domain/entities/event.dart';

class AIQuestionGenerator {
  static final _random = Random();
  static int _index = 0;

  static String generateMorningQuestion(User user, List<Event> recentEvents) {
    final questions = _getMorningQuestions(user, recentEvents);
    _index = (_index + 1) % questions.length;
    return questions[_index];
  }

  static String generateEveningQuestion(User user, List<Event> todayEvents) {
    final avgFeeling = todayEvents.isEmpty
        ? 0
        : todayEvents.map((e) => e.feelingLevel).reduce((a, b) => a + b) ~/
            todayEvents.length;

    final avgReaction = todayEvents.isEmpty
        ? 0
        : todayEvents.map((e) => e.reactionLevel).reduce((a, b) => a + b) ~/
            todayEvents.length;

    if (avgReaction > avgFeeling && todayEvents.isNotEmpty) {
      return 'Oggi le tue reazioni sono state più intense delle sensazioni. Cosa ti ha fatto perdere il controllo?';
    }

    final eveningQuestions = [
      'Oggi hai agito secondo i tuoi valori? Quale valore hai onorato di più?',
      'Cosa avresti fatto diversamente oggi se potessi tornare indietro?',
      'Hai affrontato qualcosa di difficile oggi? Come ti sei sentito dopo?',
      'Qual è stata la cosa più importante che hai imparato oggi?',
      'Se un amico ti avesse osservato oggi, di cosa sarebbe stato orgoglioso?',
      'Hai dedicato tempo alla crescita personale oggi?',
      'Cosa hai fatto oggi per avvicinarti all\'uomo che vuoi diventare?',
      'Hai avuto modo di essere grato per qualcosa oggi?',
    ];

    return eveningQuestions[_random.nextInt(eveningQuestions.length)];
  }

  static String generateOnDemandChallenge(User user) {
    final challenges = _getChallengesForProfile(user);
    return challenges[_random.nextInt(challenges.length)];
  }

  static String generateEventReflection(Event event) {
    if (event.reactionLevel > event.feelingLevel) {
      final reflections = [
        'La tua reazione ha rivelato qualcosa su ciò che realmente ti sta a cuore.',
        'Quando reagiamo più intensamente del necessario, spesso è perché tocchiamo ferite più profonde.',
        'La differenza tra sensazione e reazione è dove si nasconde la crescita.',
        'Ogni reazione eccessiva è un\'opportunità per conoscerti meglio.',
      ];
      return reflections[_random.nextInt(reflections.length)];
    }

    final positive = [
      'Hai mantenuto la calma. Questo è il segno di una mente allenata.',
      'La tua risposta è stata proporzionata. Continua così.',
      'Ottimo equilibrio tra percezione e reazione.',
    ];
    return positive[_random.nextInt(positive.length)];
  }

  static List<String> _getMorningQuestions(
      User user, List<Event> recentEvents) {
    final baseQuestions = [
      'Cosa ti impedisce di dormire la notte?',
      'Cosa faresti se non avessi paura del giudizio degli altri?',
      'Qual è la decisione più importante che devi prendere?',
      'Chi hai deluso di recente, e perché?',
      'Cosa eviti che sai di dover affrontare?',
      'Se questa fosse la tua ultima settimana, cosa cambieresti?',
      'Cosa vuoi davvero, al di là di ciò che pensi di volere?',
      'Di cosa hai bisogno ma non sai chiedere?',
      'Quale bugia ti racconti ogni giorno?',
      'Cosa penseresti di te stesso se fossi il tuo migliore amico?',
      'Cosa stai sacrificando per la tua comfort zone?',
      'Se potessi parlare con il te stesso di 10 anni fa, cosa gli diresti?',
    ];

    if (user.stressResponse.contains('fuga') ||
        user.stressResponse.contains('evito')) {
      return [
        ...baseQuestions,
        'Cosa stai evitando in questo momento?',
        'Cosa accadrebbe se affrontassi la cosa che temi?',
        'La fuga ti sta proteggendo o limitando?',
      ];
    }

    if (user.avoidedThings.isNotEmpty) {
      return [
        ...baseQuestions,
        'Hai affrontato "${user.avoidedThings.first}" ultimamente?',
        'Cosa ti trattiene dal fare ciò che sai di dover fare?',
      ];
    }

    return baseQuestions;
  }

  static List<String> _getChallengesForProfile(User user) {
    final challenges = <String>[
      'Chiama qualcuno a cui non parli da tempo e chiedi come sta.',
      'Scrivi una lettera a te stesso che leggerai tra 30 giorni.',
      'Identifica una cosa che eviti e impegnati a farla entro 24 ore.',
      'Per un giorno intero, rispondi onestamente a ogni domanda.',
      'Fai qualcosa di cui hai vergogna e accetta la vulnerabilità.',
      'Dì "no" a qualcosa che non vuoi fare, senza scuse.',
      'Condividi un tuo errore recente con qualcuno di fiducia.',
      'Dedica 30 minuti a riflettere su ciò che ti rende veramente felice.',
      'Smetti di lamentarti per un giorno intero.',
      'Fai qualcosa di generoso senza aspettarti nulla in cambio.',
    ];

    if (user.coreValues.contains('Coraggio')) {
      challenges.add('Fai qualcosa che ti spaventa oggi, anche piccolo.');
    }

    if (user.coreValues.contains('Onestà')) {
      challenges.add('Dì una verità scomoda a qualcuno oggi.');
    }

    if (user.coreValues.contains('Disciplina')) {
      challenges.add('Completa un compito noioso che hai rimandato.');
    }

    return challenges;
  }

  static String getRandomQuote() {
    final quotes = [
      'La disciplina è scelta tra ciò che vuoi ora e ciò che vuoi di più.',
      'Non è chi sei, ma chi scegli di essere ogni giorno.',
      'Il dolore è inevitabile, la sofferenza è una scelta.',
      'Controlla ciò che puoi, accetta ciò che non puoi.',
      'Oggi è il giorno in cui diventi l\'uomo che vuoi essere.',
      'La forza non viene dal corpo, ma dalla volontà.',
      'Ogni sfida è un\'opportunità per diventare più forte.',
      'Il coraggio non è l\'assenza di paura, è agire nonostante essa.',
      'Sii il cambiamento che vuoi vedere nel mondo, starting from yourself.',
      'La vera vittoria è conquistare te stesso.',
    ];
    return quotes[_random.nextInt(quotes.length)];
  }
}
