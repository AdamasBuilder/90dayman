import 'dart:math';
import '../../domain/entities/user.dart';

class StoicQuotes {
  static final _random = Random();
  
  static final List<Map<String, String>> _marcusAureliusQuotes = [
    {
      'text': 'La vita dell\'uomo è ciò che i suoi pensieri fanno di lui.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'Non è la cosa in sé a turbarci, ma il nostro giudizio su di essa.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'Hai potere sulla tua mente, non sugli eventi esterni. Realizza questo e troverai la forza.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'Memento mori. Ricorda che morirai; questo è il pensiero che libera.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'Il tempo è come un fiume fatto di momenti che passano.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'Non lasciare che il mondo ti influenzi oltre la tua mente.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'La tua mente è ciò che crea il tuo inferno o paradiso.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'Ogni giorno è l\'ultimo. Vivi come se fosse l\'eternità.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'La virtù è l\'unica cosa che non può essere tolta.',
      'source': 'Marco Aurelius, Meditations'
    },
    {
      'text': 'Sii come la roccia: le onde la colpiscono ma resta salda.',
      'source': 'Marco Aurelius, Meditations'
    },
  ];

  static final List<Map<String, String>> _senecaQuotes = [
    {
      'text': 'Non è perché le cose sono difficili che non osiamo; è perché non osiamo che sono difficili.',
      'source': 'Seneca'
    },
    {
      'text': 'La vita breve se la usiamo bene, è sufficientemente lunga.',
      'source': 'Seneca, Lettere a Lucilio'
    },
    {
      'text': 'Non esiste vento favorevole per chi non sa dove vuole andare.',
      'source': 'Seneca'
    },
    {
      'text': 'Il coraggio è la virtù che rende possibile tutto il resto.',
      'source': 'Seneca'
    },
    {
      'text': 'Siamo schiavi di tutto ciò che ci impedisce di agire.',
      'source': 'Seneca'
    },
    {
      'text': 'La felicità si trova nella libertà interiore.',
      'source': 'Seneca'
    },
    {
      'text': 'Impara non solo a sopportare i mali, ma a trasformarli in beni.',
      'source': 'Seneca'
    },
    {
      'text': 'Il tempo guarisce ciò che la ragione non può.',
      'source': 'Seneca'
    },
    {
      'text': 'Non c\'è uomo libero che non sia padrone di sé.',
      'source': 'Seneca'
    },
    {
      'text': 'Ogni uomo è artefice del proprio destino.',
      'source': 'Seneca'
    },
  ];

  static final List<Map<String, String>> _epictetusQuotes = [
    {
      'text': 'Prima impara il significato di ciò che dici, poi parla.',
      'source': 'Epitteto, Enchiridion'
    },
    {
      'text': 'Fatti non foste per viver come bruti, ma per seguir virtute e canoscenza.',
      'source': 'Epitteto'
    },
    {
      'text': 'Gli uomini non sono disturbati dalle cose, ma dai loro giudizi.',
      'source': 'Epitteto, Enchiridion'
    },
    {
      'text': 'C\'è solo un modo per essere felici: smettere di preoccuparsi.',
      'source': 'Epitteto'
    },
    {
      'text': 'Controlla i tuoi desideri, evita le tue paure.',
      'source': 'Epitteto, Enchiridion'
    },
    {
      'text': 'Se vuoi migliorare, sii disposto a sembrare stupido.',
      'source': 'Epitteto'
    },
    {
      'text': 'Non cercare che tutto accada come vuoi tu; desidera che accada come capita.',
      'source': 'Epitteto, Enchiridion'
    },
    {
      'text': 'La ricchezza non è bene, né il suo opposto. Il bene è solo la virtù.',
      'source': 'Epitteto'
    },
    {
      'text': 'Chi è libero da passioni è come una fortezza.',
      'source': 'Epitteto'
    },
    {
      'text': 'Scegli di non essere schiavo di ciò che non dipende da te.',
      'source': 'Epitteto, Enchiridion'
    },
  ];

  static Map<String, String> getRandomQuote() {
    final allQuotes = [..._marcusAureliusQuotes, ..._senecaQuotes, ..._epictetusQuotes];
    return allQuotes[_random.nextInt(allQuotes.length)];
  }

  static Map<String, String> getQuoteByAuthor(String author) {
    switch (author.toLowerCase()) {
      case 'marcus':
      case 'marcus aurelius':
      case 'marco':
        return _marcusAureliusQuotes[_random.nextInt(_marcusAureliusQuotes.length)];
      case 'seneca':
        return _senecaQuotes[_random.nextInt(_senecaQuotes.length)];
      case 'epictetus':
      case 'epitteto':
        return _epictetusQuotes[_random.nextInt(_epictetusQuotes.length)];
      default:
        return getRandomQuote();
    }
  }

  static Map<String, String> getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final allQuotes = [..._marcusAureliusQuotes, ..._senecaQuotes, ..._epictetusQuotes];
    return allQuotes[dayOfYear % allQuotes.length];
  }

  static String getGreeting(User user) {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Il giorno è nuovo, ${user.name}. Sei pronto a combattere la battaglia più importante?';
    } else if (hour >= 12 && hour < 17) {
      return 'A metà strada, ${user.name}. Come procede la tua disciplina?';
    } else if (hour >= 17 && hour < 21) {
      return 'La luce cala, ${user.name}. Quale uomo sei stato oggi?';
    } else {
      return 'Nel silenzio della notte, ${user.name}, rifletti sulla tua giornata.';
    }
  }

  static String getMorningMotivation(int currentDay) {
    final progress = (currentDay / 90 * 100).toInt();
    return 'Giorno $currentDay su 90 ($progress% completato). Ogni giorno è un passo verso la tua trasformazione.';
  }

  static String getEveningReflection(int currentDay) {
    return 'Giorno $currentDay quasi finito. Quale uomo sei diventato oggi?';
  }
}
