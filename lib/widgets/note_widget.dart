import 'package:flutter/material.dart';


class NoteWidget extends StatelessWidget {
  final String content;
  final NoteType type;
  final VoidCallback? onDelete;

  const NoteWidget({
    super.key,
    required this.content,
    this.type = NoteType.info,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: _getBorderColor(), width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getTitleColor(),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20.0),
              color: Colors.grey,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case NoteType.info:
        return Colors.blue.withValues(alpha: 0.1);
      case NoteType.warning:
        return Colors.orange.withValues(alpha: 0.1);
      case NoteType.error:
        return Colors.red.withValues(alpha: 0.1);
      case NoteType.success:
        return Colors.green.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case NoteType.info:
        return Colors.blue.withValues(alpha: 0.3);
      case NoteType.warning:
        return Colors.orange.withValues(alpha: 0.3);
      case NoteType.error:
        return Colors.red.withValues(alpha: 0.3);
      case NoteType.success:
        return Colors.green.withValues(alpha: 0.3);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case NoteType.info:
        return Icons.info_outline;
      case NoteType.warning:
        return Icons.warning_amber_outlined;
      case NoteType.error:
        return Icons.error_outline;
      case NoteType.success:
        return Icons.check_circle_outline;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case NoteType.info:
        return Colors.blue;
      case NoteType.warning:
        return Colors.orange;
      case NoteType.error:
        return Colors.red;
      case NoteType.success:
        return Colors.green;
    }
  }

  Color _getTitleColor() {
    switch (type) {
      case NoteType.info:
        return Colors.blue.shade800;
      case NoteType.warning:
        return Colors.orange.shade800;
      case NoteType.error:
        return Colors.red.shade800;
      case NoteType.success:
        return Colors.green.shade800;
    }
  }

  String _getTitle() {
    switch (type) {
      case NoteType.info:
        return 'ملاحظة';
      case NoteType.warning:
        return 'تنبيه';
      case NoteType.error:
        return 'خطأ';
      case NoteType.success:
        return 'نجاح';
    }
  }
}

enum NoteType {
  info,
  warning,
  error,
  success,
}