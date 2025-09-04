import 'package:flutter/material.dart';

enum AchievementType {
  firstLesson,
  firstQuiz,
  perfectScore,
  streakLearner,
  fastLearner,
  dedicated,
  explorer,
  master,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final int requiredValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.requiredValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    AchievementType? type,
    int? requiredValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      requiredValue: requiredValue ?? this.requiredValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'color': color.toARGB32(),
      'type': type.index,
      'requiredValue': requiredValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      type: AchievementType.values[json['type']],
      requiredValue: json['requiredValue'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
          : null,
    );
  }
}

class AchievementData {
  static List<Achievement> getAllAchievements() {
    return [
      const Achievement(
        id: 'first_lesson',
        title: 'البداية الأولى',
        description: 'أكمل أول درس لك',
        icon: Icons.play_circle_filled,
        color: Colors.green,
        type: AchievementType.firstLesson,
        requiredValue: 1,
      ),
      const Achievement(
        id: 'first_quiz',
        title: 'المختبر الأول',
        description: 'أكمل أول اختبار لك',
        icon: Icons.quiz,
        color: Colors.blue,
        type: AchievementType.firstQuiz,
        requiredValue: 1,
      ),
      const Achievement(
        id: 'perfect_score',
        title: 'الدرجة الكاملة',
        description: 'احصل على 100% في اختبار',
        icon: Icons.star,
        color: Colors.amber,
        type: AchievementType.perfectScore,
        requiredValue: 100,
      ),
      const Achievement(
        id: 'streak_learner',
        title: 'المتعلم المثابر',
        description: 'تعلم لمدة 7 أيام متتالية',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        type: AchievementType.streakLearner,
        requiredValue: 7,
      ),
      const Achievement(
        id: 'fast_learner',
        title: 'المتعلم السريع',
        description: 'أكمل 5 دروس في يوم واحد',
        icon: Icons.speed,
        color: Colors.purple,
        type: AchievementType.fastLearner,
        requiredValue: 5,
      ),
      const Achievement(
        id: 'dedicated',
        title: 'المتفاني',
        description: 'أكمل 50 درس',
        icon: Icons.school,
        color: Colors.indigo,
        type: AchievementType.dedicated,
        requiredValue: 50,
      ),
      const Achievement(
        id: 'explorer',
        title: 'المستكشف',
        description: 'ادخل على جميع الأقسام',
        icon: Icons.explore,
        color: Colors.teal,
        type: AchievementType.explorer,
        requiredValue: 5,
      ),
      const Achievement(
        id: 'master',
        title: 'الخبير',
        description: 'أكمل جميع الفصول',
        icon: Icons.emoji_events,
        color: Colors.red,
        type: AchievementType.master,
        requiredValue: 100,
      ),
    ];
  }
}
