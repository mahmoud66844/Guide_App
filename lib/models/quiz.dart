import 'package:hive/hive.dart';

part 'quiz.g.dart';

@HiveType(typeId: 2)
class Quiz {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String lessonId;

  @HiveField(2)
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.lessonId,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'questions': questions.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 3)
class Question {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final List<String> options;

  @HiveField(3)
  final int answerIndex;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.answerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['q'] as String,
      options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      answerIndex: json['answerIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'q': text,
      'options': options,
      'answerIndex': answerIndex,
    };
  }
}