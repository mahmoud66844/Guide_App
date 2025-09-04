import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:guide_app/models/achievement.dart';

class AchievementService {
  static const String _achievementsKey = 'user_achievements';
  static const String _statsKey = 'user_stats';

  // إحصائيات المستخدم
  static Future<Map<String, int>> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      final Map<String, dynamic> statsMap = json.decode(statsJson);
      return statsMap.map((key, value) => MapEntry(key, value as int));
    }

    return {
      'lessonsCompleted': 0,
      'quizzesCompleted': 0,
      'perfectScores': 0,
      'currentStreak': 0,
      'maxStreak': 0,
      'lessonsToday': 0,
      'sectionsVisited': 0,
      'chaptersCompleted': 0,
      'totalStudyTime': 0, // بالدقائق
    };
  }

  // تحديث إحصائية معينة
  static Future<void> updateStat(String statName, int value) async {
    final stats = await getUserStats();
    stats[statName] = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(stats));

    // فحص الشارات بعد تحديث الإحصائيات
    await _checkAchievements();
  }

  // زيادة إحصائية معينة
  static Future<void> incrementStat(String statName, [int increment = 1]) async {
    final stats = await getUserStats();
    stats[statName] = (stats[statName] ?? 0) + increment;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, json.encode(stats));

    // فحص الشارات بعد تحديث الإحصائيات
    await _checkAchievements();
  }

  // الحصول على الشارات المفتوحة
  static Future<List<Achievement>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);

    if (achievementsJson != null) {
      final List<dynamic> achievementsList = json.decode(achievementsJson);
      return achievementsList
          .map((json) => Achievement.fromJson(json))
          .where((achievement) => achievement.isUnlocked)
          .toList();
    }

    return [];
  }

  // الحصول على جميع الشارات مع حالتها
  static Future<List<Achievement>> getAllAchievementsWithStatus() async {
    final allAchievements = AchievementData.getAllAchievements();
    final unlockedAchievements = await getUnlockedAchievements();

    return allAchievements.map((achievement) {
      final unlocked = unlockedAchievements.firstWhere(
        (unlocked) => unlocked.id == achievement.id,
        orElse: () => achievement,
      );

      return achievement.copyWith(
        isUnlocked: unlocked.isUnlocked,
        unlockedAt: unlocked.unlockedAt,
      );
    }).toList();
  }

  // فحص وفتح الشارات الجديدة
  static Future<List<Achievement>> _checkAchievements() async {
    final stats = await getUserStats();
    final allAchievements = await getAllAchievementsWithStatus();
    final newlyUnlocked = <Achievement>[];

    for (final achievement in allAchievements) {
      if (!achievement.isUnlocked && _shouldUnlockAchievement(achievement, stats)) {
        final unlockedAchievement = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        newlyUnlocked.add(unlockedAchievement);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _saveUnlockedAchievements(newlyUnlocked);
    }

    return newlyUnlocked;
  }

  // تحديد ما إذا كان يجب فتح الشارة
  static bool _shouldUnlockAchievement(Achievement achievement, Map<String, int> stats) {
    switch (achievement.type) {
      case AchievementType.firstLesson:
        return (stats['lessonsCompleted'] ?? 0) >= 1;
      case AchievementType.firstQuiz:
        return (stats['quizzesCompleted'] ?? 0) >= 1;
      case AchievementType.perfectScore:
        return (stats['perfectScores'] ?? 0) >= 1;
      case AchievementType.streakLearner:
        return (stats['maxStreak'] ?? 0) >= achievement.requiredValue;
      case AchievementType.fastLearner:
        return (stats['lessonsToday'] ?? 0) >= achievement.requiredValue;
      case AchievementType.dedicated:
        return (stats['lessonsCompleted'] ?? 0) >= achievement.requiredValue;
      case AchievementType.explorer:
        return (stats['sectionsVisited'] ?? 0) >= achievement.requiredValue;
      case AchievementType.master:
        return (stats['chaptersCompleted'] ?? 0) >= achievement.requiredValue;
    }
  }

  // حفظ الشارات المفتوحة
  static Future<void> _saveUnlockedAchievements(List<Achievement> newAchievements) async {
    final currentUnlocked = await getUnlockedAchievements();
    final allUnlocked = [...currentUnlocked, ...newAchievements];

    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = json.encode(
      allUnlocked.map((achievement) => achievement.toJson()).toList(),
    );
    await prefs.setString(_achievementsKey, achievementsJson);
  }

  // أحداث التعلم - يتم استدعاؤها من أجزاء مختلفة من التطبيق
  static Future<List<Achievement>> onLessonCompleted() async {
    await incrementStat('lessonsCompleted');
    await incrementStat('lessonsToday');
    return await _checkAchievements();
  }

  static Future<List<Achievement>> onQuizCompleted(int score) async {
    await incrementStat('quizzesCompleted');
    if (score == 100) {
      await incrementStat('perfectScores');
    }
    return await _checkAchievements();
  }

  static Future<List<Achievement>> onChapterCompleted() async {
    await incrementStat('chaptersCompleted');
    return await _checkAchievements();
  }

  static Future<List<Achievement>> onSectionVisited() async {
    await incrementStat('sectionsVisited');
    return await _checkAchievements();
  }

  // تحديث الـ streak اليومي
  static Future<void> updateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStudyDate = prefs.getString('lastStudyDate');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastStudyDate == null) {
      // أول يوم دراسة
      await updateStat('currentStreak', 1);
      await updateStat('maxStreak', 1);
    } else if (lastStudyDate != today) {
      final lastDate = DateTime.parse(lastStudyDate);
      final todayDate = DateTime.parse(today);
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        // يوم متتالي
        final currentStreak = (await getUserStats())['currentStreak'] ?? 0;
        final newStreak = currentStreak + 1;
        await updateStat('currentStreak', newStreak);

        final maxStreak = (await getUserStats())['maxStreak'] ?? 0;
        if (newStreak > maxStreak) {
          await updateStat('maxStreak', newStreak);
        }
      } else {
        // انقطع الـ streak
        await updateStat('currentStreak', 1);
      }
    }

    await prefs.setString('lastStudyDate', today);
    // إعادة تعيين دروس اليوم إذا كان يوم جديد
    if (lastStudyDate != today) {
      await updateStat('lessonsToday', 0);
    }
  }

  // الحصول على نسبة التقدم للشارة
  static Future<double> getAchievementProgress(Achievement achievement) async {
    final stats = await getUserStats();

    switch (achievement.type) {
      case AchievementType.firstLesson:
        return ((stats['lessonsCompleted'] ?? 0) / achievement.requiredValue).clamp(0.0, 1.0);
      case AchievementType.firstQuiz:
        return ((stats['quizzesCompleted'] ?? 0) / achievement.requiredValue).clamp(0.0, 1.0);
      case AchievementType.perfectScore:
        return ((stats['perfectScores'] ?? 0) / achievement.requiredValue).clamp(0.0, 1.0);
      case AchievementType.streakLearner:
        return ((stats['maxStreak'] ?? 0) / achievement.requiredValue).clamp(0.0, 1.0);
      case AchievementType.fastLearner:
        return ((stats['lessonsToday'] ?? 0) / achievement.requiredValue).clamp(0.0, 1.0);
      case AchievementType.dedicated:
        return ((stats['lessonsCompleted'] ?? 0) / achievement.requiredValue).clamp(0.0, 1.0);
      case AchievementType.explorer:
        return ((stats['sectionsVisited'] ?? 0) / achievement.requiredValue).clamp(0.0, 1.0);
      case AchievementType.master:
        return ((stats['chaptersCompleted'] ?? 0) / achievement.requiredValue).clamp(0.0, 1.0);
    }
  }
}
