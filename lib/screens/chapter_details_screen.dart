import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guide_app/theme/app_theme.dart';

class ChapterDetailsScreen extends StatelessWidget {
  final String chapterId;

  const ChapterDetailsScreen({
    super.key,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    // في التطبيق الحقيقي، سنجلب هذه البيانات من قاعدة البيانات
    final String chapterTitle = chapterId == 'chapter1'
        ? 'الفصل الأول: أساسيات التطبيق'
        : chapterId == 'chapter2'
            ? 'الفصل الثاني: المميزات المتقدمة'
            : 'الفصل';

    return Scaffold(
      appBar: AppBar(
        title: Text(chapterTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'chapter-$chapterId',
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: const Center(
                  child: Icon(
                    Icons.book,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapterTitle,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هذا الفصل يحتوي على مجموعة من الدروس التي ستساعدك على فهم أساسيات التطبيق وكيفية استخدامه بشكل فعال.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
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
                  const SizedBox(height: 24),
                  Text(
                    'الدروس',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  _buildLessonItem(
                    context,
                    'الدرس 1: مقدمة في التطبيق',
                    'تعرف على الواجهة الرئيسية للتطبيق وكيفية التنقل بين الشاشات',
                    'lesson1',
                    true,
                    0.4,
                  ),
                  const SizedBox(height: 12),
                  _buildLessonItem(
                    context,
                    'الدرس 2: إنشاء حساب جديد',
                    'تعلم كيفية إنشاء حساب جديد وتسجيل الدخول إلى التطبيق',
                    'lesson2',
                    false,
                    0.0,
                  ),
                  const SizedBox(height: 12),
                  _buildLessonItem(
                    context,
                    'الدرس 3: تخصيص الإعدادات',
                    'تعلم كيفية تخصيص إعدادات التطبيق حسب احتياجاتك',
                    'lesson3',
                    false,
                    0.0,
                  ),
                  const SizedBox(height: 12),
                  _buildLessonItem(
                    context,
                    'الدرس 4: استخدام البحث',
                    'تعلم كيفية استخدام ميزة البحث للعثور على المحتوى بسرعة',
                    'lesson4',
                    false,
                    0.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // تنزيل الفصل للاستخدام بدون اتصال
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('جاري تنزيل الفصل للاستخدام بدون اتصال...'),
            ),
          );
        },
        icon: const Icon(Icons.download),
        label: const Text('تنزيل الفصل'),
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    String title,
    String description,
    String lessonId,
    bool isStarted,
    double progress,
  ) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/lesson/$lessonId'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isStarted
                          ? AppTheme.accentColor.withValues(alpha: 0.2)
                          : AppTheme.primaryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isStarted ? Icons.play_arrow : Icons.lock_open,
                      color: isStarted ? AppTheme.accentColor : AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isStarted) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}% مكتمل',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}