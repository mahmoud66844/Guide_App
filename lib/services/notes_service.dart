import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guide_app/models/note.dart';

class NotesService {
  static const String _notesKey = 'user_notes';

  // الحصول على جميع الملاحظات
  static Future<List<Note>> getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_notesKey);
    
    if (notesJson != null) {
      final List<dynamic> notesList = json.decode(notesJson);
      return notesList.map((json) => Note.fromJson(json)).toList();
    }
    
    return [];
  }

  // الحصول على ملاحظات درس معين
  static Future<List<Note>> getNotesByLesson(String lessonId) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.lessonId == lessonId).toList();
  }

  // الحصول على ملاحظات فصل معين
  static Future<List<Note>> getNotesByChapter(String chapterId) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.chapterId == chapterId).toList();
  }

  // الحصول على الملاحظات المثبتة
  static Future<List<Note>> getPinnedNotes() async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.isPinned).toList();
  }

  // البحث في الملاحظات
  static Future<List<Note>> searchNotes(String query) async {
    final allNotes = await getAllNotes();
    final lowerQuery = query.toLowerCase();
    
    return allNotes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
             note.content.toLowerCase().contains(lowerQuery) ||
             note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // إضافة ملاحظة جديدة
  static Future<void> addNote(Note note) async {
    final allNotes = await getAllNotes();
    allNotes.add(note);
    await _saveNotes(allNotes);
  }

  // تحديث ملاحظة
  static Future<void> updateNote(Note updatedNote) async {
    final allNotes = await getAllNotes();
    final index = allNotes.indexWhere((note) => note.id == updatedNote.id);
    
    if (index != -1) {
      allNotes[index] = updatedNote.copyWith(updatedAt: DateTime.now());
      await _saveNotes(allNotes);
    }
  }

  // حذف ملاحظة
  static Future<void> deleteNote(String noteId) async {
    final allNotes = await getAllNotes();
    allNotes.removeWhere((note) => note.id == noteId);
    await _saveNotes(allNotes);
  }

  // تثبيت/إلغاء تثبيت ملاحظة
  static Future<void> togglePinNote(String noteId) async {
    final allNotes = await getAllNotes();
    final index = allNotes.indexWhere((note) => note.id == noteId);
    
    if (index != -1) {
      allNotes[index] = allNotes[index].copyWith(
        isPinned: !allNotes[index].isPinned,
        updatedAt: DateTime.now(),
      );
      await _saveNotes(allNotes);
    }
  }

  // الحصول على ملاحظة بالمعرف
  static Future<Note?> getNoteById(String noteId) async {
    final allNotes = await getAllNotes();
    try {
      return allNotes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  // الحصول على الملاحظات حسب النوع
  static Future<List<Note>> getNotesByType(NoteType type) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.type == type).toList();
  }

  // الحصول على الملاحظات حسب التاريخ
  static Future<List<Note>> getNotesByDateRange(DateTime start, DateTime end) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) {
      return note.createdAt.isAfter(start) && note.createdAt.isBefore(end);
    }).toList();
  }

  // الحصول على جميع التاجات المستخدمة
  static Future<List<String>> getAllTags() async {
    final allNotes = await getAllNotes();
    final Set<String> tags = {};
    
    for (final note in allNotes) {
      tags.addAll(note.tags);
    }
    
    return tags.toList()..sort();
  }

  // الحصول على الملاحظات حسب التاج
  static Future<List<Note>> getNotesByTag(String tag) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) => note.tags.contains(tag)).toList();
  }

  // حفظ الملاحظات
  static Future<void> _saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(
      notes.map((note) => note.toJson()).toList(),
    );
    await prefs.setString(_notesKey, notesJson);
  }

  // إنشاء ملاحظة جديدة
  static Note createNote({
    required String lessonId,
    required String chapterId,
    required String title,
    required String content,
    NoteType type = NoteType.text,
    Color color = Colors.blue,
    List<String> tags = const [],
    bool isPinned = false,
  }) {
    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: lessonId,
      chapterId: chapterId,
      title: title,
      content: content,
      type: type,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
      isPinned: isPinned,
    );
  }

  // الحصول على إحصائيات الملاحظات
  static Future<Map<String, int>> getNotesStats() async {
    final allNotes = await getAllNotes();
    
    return {
      'total': allNotes.length,
      'pinned': allNotes.where((note) => note.isPinned).length,
      'text': allNotes.where((note) => note.type == NoteType.text).length,
      'important': allNotes.where((note) => note.type == NoteType.important).length,
      'question': allNotes.where((note) => note.type == NoteType.question).length,
      'reminder': allNotes.where((note) => note.type == NoteType.reminder).length,
    };
  }

  // تصدير الملاحظات كـ JSON
  static Future<String> exportNotesAsJson() async {
    final allNotes = await getAllNotes();
    return json.encode(allNotes.map((note) => note.toJson()).toList());
  }

  // استيراد الملاحظات من JSON
  static Future<void> importNotesFromJson(String jsonString) async {
    try {
      final List<dynamic> notesList = json.decode(jsonString);
      final notes = notesList.map((json) => Note.fromJson(json)).toList();
      await _saveNotes(notes);
    } catch (e) {
      throw Exception('فشل في استيراد الملاحظات: $e');
    }
  }
}
