import 'package:hive/hive.dart';

part 'lesson.g.dart';

@HiveType(typeId: 1)
class Lesson {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chapterId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final int order;

  @HiveField(4)
  final String body;

  @HiveField(5)
  final List<String> media;

  Lesson({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.order,
    required this.body,
    this.media = const [],
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      chapterId: json['chapterId'] as String,
      title: json['title'] as String,
      order: json['order'] as int,
      body: json['body'] as String,
      media: (json['media'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterId': chapterId,
      'title': title,
      'order': order,
      'body': body,
      'media': media,
    };
  }
}