import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:guide_app/theme/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:guide_app/services/achievement_service.dart';
import 'package:guide_app/screens/note_editor_screen.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // في التطبيق الحقيقي، سنجلب هذه البيانات من قاعدة البيانات
    if (widget.lessonId == 'lesson1') {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    // استخدم رابط فيديو حقيقي في التطبيق الفعلي
    _videoController = VideoPlayerController.networkUrl(Uri.parse(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'));

    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'حدث خطأ أثناء تحميل الفيديو: $errorMessage',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );

    setState(() {
      _isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    if (_chewieController != null) {
      _chewieController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // في التطبيق الحقيقي، سنجلب هذه البيانات من قاعدة البيانات
    final String lessonTitle = widget.lessonId == 'lesson1'
        ? 'الدرس 1: مقدمة في التطبيق'
        : 'الدرس';

    return Scaffold(
      appBar: AppBar(
        title: Text(lessonTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت إضافة الدرس إلى المفضلة'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تمت مشاركة الدرس'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isVideoInitialized && _chewieController != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Chewie(controller: _chewieController!),
              )
            else if (widget.lessonId == 'lesson1')
              const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lessonTitle,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16),
                  const Markdown(
                    data: '''
# مقدمة في التطبيق

هذا الدرس يقدم مقدمة شاملة عن التطبيق وكيفية استخدامه بشكل فعال.

## الواجهة الرئيسية

الواجهة الرئيسية للتطبيق تحتوي على العناصر التالية:

- **الشاشة الرئيسية**: تعرض الفصول والدروس المتاحة
- **قائمة الفصول**: تعرض جميع الفصول المتاحة في التطبيق
- **الإعدادات**: تتيح لك تخصيص التطبيق حسب احتياجاتك

## كيفية التنقل

يمكنك التنقل بين الشاشات المختلفة باستخدام:

1. شريط التنقل السفلي
2. الأزرار في الشاشة الرئيسية
3. الضغط على العناصر المختلفة

## تتبع التقدم

يتيح لك التطبيق تتبع تقدمك في كل درس وفصل، ويعرض لك نسبة الإكمال والنقاط التي حصلت عليها.

## الاختبارات القصيرة

بعد كل درس، هناك اختبار قصير للتأكد من فهمك للمحتوى. يجب عليك الإجابة على جميع الأسئلة بشكل صحيح للانتقال إلى الدرس التالي.
''',
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  // العودة إلى الفصل
                  context.pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('العودة'),
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _completeLesson(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('إكمال الدرس'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // الانتقال إلى الاختبار
                        context.push('/quiz/quiz1');
                      },
                      child: const Text('بدء الاختبار'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // فتح محرر الملاحظات
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(
                            lessonId: widget.lessonId,
                            chapterId: 'chapter1', // يمكن تمريره كمعامل
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.note_add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeLesson() async {
    try {
      // تسجيل إكمال الدرس
      await AchievementService.updateDailyStreak();
      final newAchievements = await AchievementService.onLessonCompleted();

      if (!mounted) return;

      // عرض الشارات الجديدة إن وجدت
      if (newAchievements.isNotEmpty) {
        _showNewAchievements(newAchievements);
      }

      // إظهار رسالة إكمال الدرس
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إكمال الدرس بنجاح! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNewAchievements(List<dynamic> achievements) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('شارات جديدة!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('مبروك! لقد حصلت على شارات جديدة:'),
            const SizedBox(height: 16),
            ...achievements.map((achievement) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: achievement.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: achievement.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    achievement.icon,
                    color: achievement.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          achievement.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رائع!'),
          ),
        ],
      ),
    );
  }
}