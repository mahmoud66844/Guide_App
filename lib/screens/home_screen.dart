import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guide_app/theme/app_theme.dart';
import 'package:guide_app/widgets/chapter_card.dart';
import 'package:guide_app/widgets/bottom_nav_bar.dart';
import 'package:guide_app/screens/achievements_screen.dart';
import 'package:guide_app/screens/notes_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دليل التعلم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AchievementsScreen()),
            ),
            tooltip: 'الشارات والإنجازات',
          ),
          IconButton(
            icon: const Icon(Icons.note),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesScreen()),
            ),
            tooltip: 'ملاحظاتي',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => context.push('/downloads'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك في دليل التعلم',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'استكشف الفصول والدروس وتابع تقدمك',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
              ),
              const SizedBox(height: 24),
              _buildContinueLearningSection(context),
              const SizedBox(height: 24),
              _buildChaptersSection(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildContinueLearningSection(BuildContext context) {
    // في التطبيق الحقيقي، سنجلب هذه البيانات من قاعدة البيانات
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'استمر في التعلم',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.push('/lesson/lesson1'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الدرس 1: مقدمة في التطبيق',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الفصل الأول: أساسيات التطبيق',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(
                    value: 0.4,
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '40% مكتمل',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChaptersSection(BuildContext context) {
    // في التطبيق الحقيقي، سنجلب هذه البيانات من قاعدة البيانات
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الفصول',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            TextButton(
              onPressed: () => context.push('/chapters'),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ChapterCard(
          title: 'الفصل الأول: أساسيات التطبيق',
          description: 'تعلم أساسيات استخدام التطبيق والتنقل بين الشاشات',
          progress: 0.4,
          onTap: () => context.push('/chapter/chapter1'),
        ),
        const SizedBox(height: 12),
        ChapterCard(
          title: 'الفصل الثاني: المميزات المتقدمة',
          description: 'استكشف المميزات المتقدمة في التطبيق',
          progress: 0.0,
          onTap: () => context.push('/chapter/chapter2'),
        ),
      ],
    );
  }
}