import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 0)
class Chapter {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int order;

  @HiveField(3)
  final String cover;

  @HiveField(4)
  final bool isDownloadable;

  Chapter({
    required this.id,
    required this.title,
    required this.order,
    required this.cover,
    this.isDownloadable = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      order: json['order'] as int,
      cover: json['cover'] as String,
      isDownloadable: json['isDownloadable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'order': order,
      'cover': cover,
      'isDownloadable': isDownloadable,
    };
  }
}