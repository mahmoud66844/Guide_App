import 'package:flutter/material.dart';

enum NoteType {
  text,
  important,
  question,
  reminder,
}

class Note {
  final String id;
  final String lessonId;
  final String chapterId;
  final String title;
  final String content;
  final NoteType type;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final bool isPinned;

  const Note({
    required this.id,
    required this.lessonId,
    required this.chapterId,
    required this.title,
    required this.content,
    required this.type,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isPinned = false,
  });

  Note copyWith({
    String? id,
    String? lessonId,
    String? chapterId,
    String? title,
    String? content,
    NoteType? type,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'chapterId': chapterId,
      'title': title,
      'content': content,
      'type': type.index,
      'color': color.toARGB32(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'tags': tags,
      'isPinned': isPinned,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      lessonId: json['lessonId'],
      chapterId: json['chapterId'],
      title: json['title'],
      content: json['content'],
      type: NoteType.values[json['type']],
      color: Color(json['color']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['isPinned'] ?? false,
    );
  }

  IconData get typeIcon {
    switch (type) {
      case NoteType.text:
        return Icons.note;
      case NoteType.important:
        return Icons.priority_high;
      case NoteType.question:
        return Icons.help_outline;
      case NoteType.reminder:
        return Icons.alarm;
    }
  }

  String get typeLabel {
    switch (type) {
      case NoteType.text:
        return 'ملاحظة';
      case NoteType.important:
        return 'مهم';
      case NoteType.question:
        return 'سؤال';
      case NoteType.reminder:
        return 'تذكير';
    }
  }
}
