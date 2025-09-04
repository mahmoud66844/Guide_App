import 'package:flutter/material.dart';
import 'package:guide_app/models/achievement.dart';
import 'package:guide_app/services/achievement_service.dart';
import 'package:guide_app/theme/app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  Map<String, int> _userStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final achievements = await AchievementService.getAllAchievementsWithStatus();
      final stats = await AchievementService.getUserStats();
      
      setState(() {
        _achievements = achievements;
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشارات والإنجازات'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'إحصائياتك',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // شريط التقدم العام
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الشارات المفتوحة: $unlockedCount من $totalCount',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // الإحصائيات التفصيلية
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildStatItem(
                  'الدروس المكتملة',
                  '${_userStats['lessonsCompleted'] ?? 0}',
                  Icons.play_circle_filled,
                  Colors.green,
                ),
                _buildStatItem(
                  'الاختبارات المكتملة',
                  '${_userStats['quizzesCompleted'] ?? 0}',
                  Icons.quiz,
                  Colors.blue,
                ),
                _buildStatItem(
                  'الدرجات الكاملة',
                  '${_userStats['perfectScores'] ?? 0}',
                  Icons.star,
                  Colors.amber,
                ),
                _buildStatItem(
                  'أطول سلسلة تعلم',
                  '${_userStats['maxStreak'] ?? 0} أيام',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildStatItem(
                  'دروس اليوم',
                  '${_userStats['lessonsToday'] ?? 0}',
                  Icons.today,
                  Colors.purple,
                ),
                _buildStatItem(
                  'الفصول المكتملة',
                  '${_userStats['chaptersCompleted'] ?? 0}',
                  Icons.book,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements = _achievements.where((a) => !a.isUnlocked).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (unlockedAchievements.isNotEmpty) ...[
          const Text(
            'الشارات المفتوحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...unlockedAchievements.map((achievement) => _buildAchievementCard(achievement, true)),
          const SizedBox(height: 24),
        ],
        
        if (lockedAchievements.isNotEmpty) ...[
          const Text(
            'الشارات المقفلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...lockedAchievements.map((achievement) => _buildAchievementCard(achievement, false)),
        ],
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return FutureBuilder<double>(
      future: AchievementService.getAchievementProgress(achievement),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // أيقونة الشارة
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isUnlocked 
                        ? achievement.color.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isUnlocked ? achievement.color : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: isUnlocked ? achievement.color : Colors.grey,
                    size: 30,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // معلومات الشارة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? null : Colors.grey,
                              ),
                            ),
                          ),
                          if (isUnlocked)
                            Icon(
                              Icons.check_circle,
                              color: achievement.color,
                              size: 20,
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUnlocked ? Colors.grey[600] : Colors.grey,
                        ),
                      ),
                      
                      if (!isUnlocked && progress > 0) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'التقدم: ${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      
                      if (isUnlocked && achievement.unlockedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'تم فتحها في: ${_formatDate(achievement.unlockedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
