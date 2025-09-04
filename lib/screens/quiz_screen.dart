import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guide_app/theme/app_theme.dart';
import 'package:guide_app/services/achievement_service.dart';
import 'package:guide_app/models/achievement.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  late List<int?> _selectedAnswers;
  bool _isQuizCompleted = false;
  int _score = 0;

  // في التطبيق الحقيقي، سنجلب هذه البيانات من قاعدة البيانات
  final List<Map<String, dynamic>> _questions = [
    {
      'text': 'ما هو الغرض الرئيسي من التطبيق؟',
      'options': [
        'تصفح الإنترنت',
        'تعلم مهارات جديدة',
        'التواصل الاجتماعي',
        'مشاهدة الفيديوهات',
      ],
      'correctAnswerIndex': 1,
    },
    {
      'text': 'كيف يمكنك الانتقال بين الشاشات في التطبيق؟',
      'options': [
        'باستخدام شريط التنقل السفلي',
        'بالضغط على الأزرار في الشاشة الرئيسية',
        'بالضغط على العناصر المختلفة',
        'جميع ما سبق',
      ],
      'correctAnswerIndex': 3,
    },
    {
      'text': 'ما هي الميزة التي تتيح لك متابعة تقدمك في التطبيق؟',
      'options': [
        'شارات الإنجاز',
        'نسبة الإكمال',
        'النقاط',
        'جميع ما سبق',
      ],
      'correctAnswerIndex': 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(_questions.length, null);
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      await _calculateScore();
      setState(() {
        _isQuizCompleted = true;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _calculateScore() async {
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correctAnswerIndex']) {
        correctAnswers++;
      }
    }
    _score = (correctAnswers / _questions.length * 100).round();

    // تسجيل إكمال الاختبار في نظام الشارات
    try {
      final newAchievements = await AchievementService.onQuizCompleted(_score);

      // عرض الشارات الجديدة إن وجدت
      if (newAchievements.isNotEmpty && mounted) {
        _showNewAchievements(newAchievements);
      }
    } catch (e) {
      debugPrint('خطأ في تسجيل الشارات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار: ${widget.quizId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isQuizCompleted ? _buildQuizResult() : _buildQuizQuestion(),
      ),
    );
  }

  Widget _buildQuizQuestion() {
    final question = _questions[_currentQuestionIndex];
    final options = question['options'] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: const Color(0xFFE0E0E0),
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
        ),
        const SizedBox(height: 8),
        Text(
          'سؤال ${_currentQuestionIndex + 1} من ${_questions.length}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          question['text'],
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        ...List.generate(
          options.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildAnswerOption(options[index], index),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentQuestionIndex > 0)
              TextButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('السابق'),
              )
            else
              const SizedBox(),
            ElevatedButton(
              onPressed: _selectedAnswers[_currentQuestionIndex] != null
                  ? _nextQuestion
                  : null,
              child: Text(
                _currentQuestionIndex < _questions.length - 1
                    ? 'التالي'
                    : 'إنهاء الاختبار',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerOption(String option, int index) {
    final isSelected = _selectedAnswers[_currentQuestionIndex] == index;

    return InkWell(
      onTap: () => _selectAnswer(index),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                  width: 2.0,
                ),
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResult() {
    final bool isPassed = _score >= 70;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPassed ? Colors.green.shade100 : Colors.red.shade100,
            ),
            child: Icon(
              isPassed ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: isPassed ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isPassed ? 'تهانينا!' : 'حاول مرة أخرى',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'لقد حصلت على $_score% من الإجابات الصحيحة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isPassed
                ? 'لقد اجتزت الاختبار بنجاح!'
                : 'لم تجتز الاختبار، يرجى مراجعة الدرس والمحاولة مرة أخرى.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // العودة إلى الدرس
                  context.pop();
                },
                icon: const Icon(Icons.replay),
                label: Text(isPassed ? 'العودة إلى الفصل' : 'مراجعة الدرس'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPassed ? AppTheme.primaryColor : Colors.grey,
                ),
              ),
              if (isPassed) ...[
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // الانتقال إلى الدرس التالي
                    context.go('/lesson/lesson2');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('الدرس التالي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showNewAchievements(List<Achievement> achievements) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شارة جديدة! 🏆'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              'مبروك! لقد حصلت على ${achievements.length} شارة جديدة!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('رائع!'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // فتح شاشة الشارات
              Navigator.pushNamed(context, '/achievements');
            },
            child: const Text('عرض الشارات'),
          ),
        ],
      ),
    );
  }
}