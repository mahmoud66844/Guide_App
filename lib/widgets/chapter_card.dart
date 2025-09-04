import 'package:flutter/material.dart';
import 'package:guide_app/theme/app_theme.dart';

class ChapterCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final VoidCallback onTap;
  final String? coverImage;

  const ChapterCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.onTap,
    this.coverImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coverImage != null)
              Image.network(
                coverImage!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: double.infinity,
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              )
            else
              Container(
                height: 100,
                width: double.infinity,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.book,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                  ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}