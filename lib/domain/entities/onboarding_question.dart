import 'package:equatable/equatable.dart';

enum QuestionCategory {
  stoicAttitude,
  grit,
  emotionRegulation,
  personality,
  stress
}

enum EmotionalState { veryLow, low, somewhatLow, somewhatHigh, high, veryHigh }

class OnboardingQuestion extends Equatable {
  final String id;
  final String question;
  final QuestionCategory category;
  final String source;
  final int? userResponse;

  const OnboardingQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.source,
    this.userResponse,
  });

  OnboardingQuestion copyWith({
    String? id,
    String? question,
    QuestionCategory? category,
    String? source,
    int? userResponse,
  }) {
    return OnboardingQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      category: category ?? this.category,
      source: source ?? this.source,
      userResponse: userResponse ?? this.userResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category.name,
      'source': source,
      'userResponse': userResponse,
    };
  }

  factory OnboardingQuestion.fromJson(Map<String, dynamic> json) {
    return OnboardingQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      category: QuestionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => QuestionCategory.stoicAttitude,
      ),
      source: json['source'] as String,
      userResponse: json['userResponse'] as int?,
    );
  }

  String get categoryLabel {
    switch (category) {
      case QuestionCategory.stoicAttitude:
        return 'Atitudine Stoica';
      case QuestionCategory.grit:
        return 'Grit & Determazione';
      case QuestionCategory.emotionRegulation:
        return 'Regolazione Emotiva';
      case QuestionCategory.personality:
        return 'Personalità';
      case QuestionCategory.stress:
        return 'Stress Percepito';
    }
  }

  static String getEmotionalStateLabel(int level) {
    switch (level) {
      case 1:
        return 'Per nulla';
      case 2:
        return 'Molto poco';
      case 3:
        return 'Un po\'';
      case 4:
        return 'Moderatamente';
      case 5:
        return 'Molto';
      case 6:
        return 'Estremamente';
      default:
        return '';
    }
  }

  @override
  List<Object?> get props => [id, question, category, source, userResponse];
}
