class AppConstants {
  AppConstants._();

  static const String appName = 'Uomo in 90 Giorni';
  static const int totalDays = 90;
  static const int morningHour = 7;
  static const int eveningHour = 21;
  static const int postpone15Min = 15;
  static const int postpone1Hour = 60;
  static const int maxPostpones = 3;

  static const List<String> eventTags = [
    'Lavoro',
    'Relazioni',
    'Salute',
    'Finanze',
    'Crescita',
    'Famiglia',
    'Amici',
    'Stress',
    'Successo',
    'Fallimento',
  ];

  static const Map<int, String> emotionLevels = {
    1: 'Tranquillità',
    2: 'Discomfort',
    3: 'Frustrazione',
    4: 'Rabbia/Ansia',
    5: 'Angoscia',
    6: 'Crisi',
  };

  static const Map<int, String> emotionDescriptions = {
    1: 'Accettazione totale',
    2: 'Riconoscimento del momento',
    3: 'Tentativo di adattamento',
    4: 'Reazione impulsiva',
    5: 'Paralisi o evitamento',
    6: 'Abbattimento totale',
  };
}
