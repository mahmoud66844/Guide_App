import 'package:hive/hive.dart';

part 'progress.g.dart';

@HiveType(typeId: 4)
class Progress {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String lessonId;

  @HiveField(2)
  final bool completed;

  @HiveField(3)
  final int score;

  @HiveField(4)
  final DateTime lastAccessed;

  Progress({
    required this.userId,
    required this.lessonId,
    this.completed = false,
    this.score = 0,
    DateTime? lastAccessed,
  }) : lastAccessed = lastAccessed ?? DateTime.now();

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      completed: json['completed'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      lastAccessed: json['lastAccessed'] != null
          ? DateTime.parse(json['lastAccessed'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'completed': completed,
      'score': score,
      'lastAccessed': lastAccessed.toIso8601String(),
    };
  }

  Progress copyWith({
    String? userId,
    String? lessonId,
    bool? completed,
    int? score,
    DateTime? lastAccessed,
  }) {
    return Progress(
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      completed: completed ?? this.completed,
      score: score ?? this.score,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }
}