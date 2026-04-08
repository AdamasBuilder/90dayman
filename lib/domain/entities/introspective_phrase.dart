import 'package:equatable/equatable.dart';

enum PhraseCategory {
  selfAwareness,
  emotionalControl,
  resilience,
  coreValues,
  action
}

class IntrospectivePhrase extends Equatable {
  final String id;
  final String text;
  final PhraseCategory category;
  final bool isSaved;
  final int? userResponse;

  const IntrospectivePhrase({
    required this.id,
    required this.text,
    required this.category,
    this.isSaved = false,
    this.userResponse,
  });

  IntrospectivePhrase copyWith({
    String? id,
    String? text,
    PhraseCategory? category,
    bool? isSaved,
    int? userResponse,
  }) {
    return IntrospectivePhrase(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      isSaved: isSaved ?? this.isSaved,
      userResponse: userResponse ?? this.userResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category.name,
      'isSaved': isSaved ? 1 : 0,
      'userResponse': userResponse,
    };
  }

  factory IntrospectivePhrase.fromJson(Map<String, dynamic> json) {
    return IntrospectivePhrase(
      id: json['id'] as String,
      text: json['text'] as String,
      category: PhraseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => PhraseCategory.selfAwareness,
      ),
      isSaved: (json['isSaved'] as int?) == 1,
      userResponse: json['userResponse'] as int?,
    );
  }

  String get categoryLabel {
    switch (category) {
      case PhraseCategory.selfAwareness:
        return 'Autoconsapevolezza';
      case PhraseCategory.emotionalControl:
        return 'Controllo Emotivo';
      case PhraseCategory.resilience:
        return 'Resilienza';
      case PhraseCategory.coreValues:
        return 'Valori Fondamentali';
      case PhraseCategory.action:
        return 'Azione';
    }
  }

  @override
  List<Object?> get props => [id, text, category, isSaved, userResponse];
}
