import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadService {
  static const String _downloadedChaptersKey = 'downloaded_chapters';

  // الحصول على قائمة الفصول المحملة
  static Future<List<String>> getDownloadedChapters() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedChapters = prefs.getStringList(_downloadedChaptersKey) ?? [];
    return downloadedChapters;
  }

  // التحقق مما إذا كان الفصل محملاً
  static Future<bool> isChapterDownloaded(String chapterId) async {
    final downloadedChapters = await getDownloadedChapters();
    return downloadedChapters.contains(chapterId);
  }

  // تنزيل فصل كامل مع الدروس والاختبارات
  static Future<bool> downloadChapter(Map<String, dynamic> chapterData) async {
    try {
      final String chapterId = chapterData['id'];

      // إنشاء مجلد للفصل
      final directory = await _getChapterDirectory(chapterId);
      await directory.create(recursive: true);

      // حفظ بيانات الفصل
      final chapterFile = File('${directory.path}/chapter_data.json');
      await chapterFile.writeAsString(jsonEncode(chapterData));

      // حفظ الدروس
      final lessons = chapterData['lessons'] as List<dynamic>;
      for (var lesson in lessons) {
        await _downloadLesson(chapterId, lesson);
      }

      // إضافة الفصل إلى قائمة الفصول المحملة
      final prefs = await SharedPreferences.getInstance();
      final downloadedChapters = prefs.getStringList(_downloadedChaptersKey) ?? [];
      if (!downloadedChapters.contains(chapterId)) {
        downloadedChapters.add(chapterId);
        await prefs.setStringList(_downloadedChaptersKey, downloadedChapters);
      }

      return true;
    } catch (e) {
      debugPrint('خطأ في تنزيل الفصل: $e');
      return false;
    }
  }

  // حذف فصل محمل
  static Future<bool> deleteDownloadedChapter(String chapterId) async {
    try {
      // حذف مجلد الفصل
      final directory = await _getChapterDirectory(chapterId);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }

      // إزالة الفصل من قائمة الفصول المحملة
      final prefs = await SharedPreferences.getInstance();
      final downloadedChapters = prefs.getStringList(_downloadedChaptersKey) ?? [];
      downloadedChapters.remove(chapterId);
      await prefs.setStringList(_downloadedChaptersKey, downloadedChapters);

      return true;
    } catch (e) {
      debugPrint('خطأ في حذف الفصل: $e');
      return false;
    }
  }

  // الحصول على بيانات فصل محمل
  static Future<Map<String, dynamic>?> getDownloadedChapterData(String chapterId) async {
    try {
      final directory = await _getChapterDirectory(chapterId);
      final chapterFile = File('${directory.path}/chapter_data.json');

      if (await chapterFile.exists()) {
        final jsonString = await chapterFile.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      debugPrint('خطأ في قراءة بيانات الفصل: $e');
      return null;
    }
  }

  // الحصول على بيانات درس محمل
  static Future<Map<String, dynamic>?> getDownloadedLessonData(String chapterId, String lessonId) async {
    try {
      final directory = await _getChapterDirectory(chapterId);
      final lessonFile = File('${directory.path}/lesson_$lessonId.json');

      if (await lessonFile.exists()) {
        final jsonString = await lessonFile.readAsString();
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      debugPrint('خطأ في قراءة بيانات الدرس: $e');
      return null;
    }
  }

  // تنزيل درس
  static Future<void> _downloadLesson(String chapterId, Map<String, dynamic> lessonData) async {
    final String lessonId = lessonData['id'];
    final directory = await _getChapterDirectory(chapterId);

    // حفظ بيانات الدرس
    final lessonFile = File('${directory.path}/lesson_$lessonId.json');
    await lessonFile.writeAsString(jsonEncode(lessonData));

    // تنزيل الوسائط المرتبطة بالدرس إذا وجدت
    if (lessonData.containsKey('media') && lessonData['media'] is List) {
      final mediaList = lessonData['media'] as List;
      for (var media in mediaList) {
        if (media is Map<String, dynamic> && media.containsKey('url')) {
          // هنا يمكن إضافة كود لتنزيل ملفات الوسائط
          // مثل الصور والفيديوهات من الخادم
        }
      }
    }

    // تنزيل الاختبارات المرتبطة بالدرس إذا وجدت
    if (lessonData.containsKey('quizzes') && lessonData['quizzes'] is List) {
      final quizzes = lessonData['quizzes'] as List;
      for (var quiz in quizzes) {
        if (quiz is Map<String, dynamic>) {
          final quizId = quiz['id'];
          final quizFile = File('${directory.path}/quiz_$quizId.json');
          await quizFile.writeAsString(jsonEncode(quiz));
        }
      }
    }
  }

  // الحصول على مسار مجلد الفصل
  static Future<Directory> _getChapterDirectory(String chapterId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/chapters/$chapterId');
  }

  // حساب حجم المحتوى المحمل
  static Future<String> getDownloadedContentSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final chaptersDir = Directory('${appDir.path}/chapters');

      if (!await chaptersDir.exists()) {
        return '0 MB';
      }

      int totalSize = 0;
      await for (var entity in chaptersDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      // تحويل الحجم إلى ميجابايت
      final sizeInMB = totalSize / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } catch (e) {
      debugPrint('خطأ في حساب حجم المحتوى: $e');
      return '0 MB';
    }
  }

  // حذف جميع المحتوى المحمل
  static Future<bool> clearAllDownloads() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final chaptersDir = Directory('${appDir.path}/chapters');

      if (await chaptersDir.exists()) {
        await chaptersDir.delete(recursive: true);
      }

      // إعادة تعيين قائمة الفصول المحملة
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_downloadedChaptersKey, []);

      return true;
    } catch (e) {
      debugPrint('خطأ في حذف جميع المحتوى المحمل: $e');
      return false;
    }
  }
}