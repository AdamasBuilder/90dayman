import 'package:equatable/equatable.dart';

enum QuestionType { morning, evening, onDemand }

class DailyQuestion extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String question;
  final QuestionType type;
  final String? answer;
  final DateTime? answeredAt;
  final bool generatedByAI;

  const DailyQuestion({
    required this.id,
    required this.userId,
    required this.date,
    required this.question,
    required this.type,
    this.answer,
    this.answeredAt,
    this.generatedByAI = true,
  });

  DailyQuestion copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? question,
    QuestionType? type,
    String? answer,
    DateTime? answeredAt,
    bool? generatedByAI,
  }) {
    return DailyQuestion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      question: question ?? this.question,
      type: type ?? this.type,
      answer: answer ?? this.answer,
      answeredAt: answeredAt ?? this.answeredAt,
      generatedByAI: generatedByAI ?? this.generatedByAI,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'question': question,
      'type': type.name,
      'answer': answer,
      'answeredAt': answeredAt?.toIso8601String(),
      'generatedByAI': generatedByAI ? 1 : 0,
    };
  }

  factory DailyQuestion.fromJson(Map<String, dynamic> json) {
    return DailyQuestion(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      question: json['question'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestionType.onDemand,
      ),
      answer: json['answer'] as String?,
      answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt'] as String) : null,
      generatedByAI: (json['generatedByAI'] as int?) == 1,
    );
  }

  bool get isAnswered => answer != null && answer!.isNotEmpty;
  
  String get typeLabel {
    switch (type) {
      case QuestionType.morning:
        return 'Domanda del Mattino';
      case QuestionType.evening:
        return 'Riflessione della Sera';
      case QuestionType.onDemand:
        return 'Sfida';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        question,
        type,
        answer,
        answeredAt,
        generatedByAI,
      ];
}
