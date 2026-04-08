import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String description;
  final List<String> tags;
  final int feelingLevel;
  final int reactionLevel;
  final String? aiReflection;
  final String? suggestedAction;

  const Event({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.description,
    this.tags = const [],
    required this.feelingLevel,
    required this.reactionLevel,
    this.aiReflection,
    this.suggestedAction,
  });

  Event copyWith({
    String? id,
    String? userId,
    DateTime? timestamp,
    String? description,
    List<String>? tags,
    int? feelingLevel,
    int? reactionLevel,
    String? aiReflection,
    String? suggestedAction,
  }) {
    return Event(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      feelingLevel: feelingLevel ?? this.feelingLevel,
      reactionLevel: reactionLevel ?? this.reactionLevel,
      aiReflection: aiReflection ?? this.aiReflection,
      suggestedAction: suggestedAction ?? this.suggestedAction,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'tags': tags.join(','),
      'feelingLevel': feelingLevel,
      'reactionLevel': reactionLevel,
      'aiReflection': aiReflection,
      'suggestedAction': suggestedAction,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      userId: json['userId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      tags: (json['tags'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [],
      feelingLevel: json['feelingLevel'] as int,
      reactionLevel: json['reactionLevel'] as int,
      aiReflection: json['aiReflection'] as String?,
      suggestedAction: json['suggestedAction'] as String?,
    );
  }

  String get emotionIntensity => feelingLevel >= reactionLevel ? 'sensazione > reazione' : 'reazione > sensazione';
  
  bool get needsWork => reactionLevel > feelingLevel;

  @override
  List<Object?> get props => [
        id,
        userId,
        timestamp,
        description,
        tags,
        feelingLevel,
        reactionLevel,
        aiReflection,
        suggestedAction,
      ];
}
