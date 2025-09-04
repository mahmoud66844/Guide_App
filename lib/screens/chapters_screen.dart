import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guide_app/widgets/chapter_card.dart';
import 'package:guide_app/widgets/bottom_nav_bar.dart';

class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفصول'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
            const SizedBox(height: 12),
            ChapterCard(
              title: 'الفصل الثالث: الإعدادات والتخصيص',
              description: 'تعلم كيفية تخصيص التطبيق وضبط الإعدادات',
              progress: 0.0,
              onTap: () => context.push('/chapter/chapter3'),
            ),
            const SizedBox(height: 12),
            ChapterCard(
              title: 'الفصل الرابع: المشاركة والتواصل',
              description: 'تعلم كيفية مشاركة المحتوى والتواصل مع المستخدمين الآخرين',
              progress: 0.0,
              onTap: () => context.push('/chapter/chapter4'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}