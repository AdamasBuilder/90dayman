import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> painPoints;
  final String selfDescription;
  final String stressResponse;
  final List<String> coreValues;
  final List<String> avoidedThings;
  final String idealSelf90Days;
  final int currentDay;
  final int streakDays;
  final bool profileComplete;

  const User({
    required this.id,
    required this.name,
    required this.createdAt,
    this.painPoints = const [],
    this.selfDescription = '',
    this.stressResponse = '',
    this.coreValues = const [],
    this.avoidedThings = const [],
    this.idealSelf90Days = '',
    this.currentDay = 1,
    this.streakDays = 0,
    this.profileComplete = false,
  });

  User copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? painPoints,
    String? selfDescription,
    String? stressResponse,
    List<String>? coreValues,
    List<String>? avoidedThings,
    String? idealSelf90Days,
    int? currentDay,
    int? streakDays,
    bool? profileComplete,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      painPoints: painPoints ?? this.painPoints,
      selfDescription: selfDescription ?? this.selfDescription,
      stressResponse: stressResponse ?? this.stressResponse,
      coreValues: coreValues ?? this.coreValues,
      avoidedThings: avoidedThings ?? this.avoidedThings,
      idealSelf90Days: idealSelf90Days ?? this.idealSelf90Days,
      currentDay: currentDay ?? this.currentDay,
      streakDays: streakDays ?? this.streakDays,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'painPoints': painPoints.join(','),
      'selfDescription': selfDescription,
      'stressResponse': stressResponse,
      'coreValues': coreValues.join(','),
      'avoidedThings': avoidedThings.join(','),
      'idealSelf90Days': idealSelf90Days,
      'currentDay': currentDay,
      'streakDays': streakDays,
      'profileComplete': profileComplete ? 1 : 0,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      painPoints: (json['painPoints'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
      selfDescription: json['selfDescription'] as String? ?? '',
      stressResponse: json['stressResponse'] as String? ?? '',
      coreValues: (json['coreValues'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
      avoidedThings: (json['avoidedThings'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
      idealSelf90Days: json['idealSelf90Days'] as String? ?? '',
      currentDay: json['currentDay'] as int? ?? 1,
      streakDays: json['streakDays'] as int? ?? 0,
      profileComplete: (json['profileComplete'] as int?) == 1,
    );
  }

  String getProfileSummary() {
    return '''
Nome: $name
Descrizione: $selfDescription
Risposta allo stress: $stressResponse
Valori: ${coreValues.join(', ')}
Cosa evita: ${avoidedThings.join(', ')}
Obiettivo 90 giorni: $idealSelf90Days
''';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        painPoints,
        selfDescription,
        stressResponse,
        coreValues,
        avoidedThings,
        idealSelf90Days,
        currentDay,
        streakDays,
        profileComplete,
      ];
}
