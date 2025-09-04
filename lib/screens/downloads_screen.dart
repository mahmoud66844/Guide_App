import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guide_app/services/download_service.dart';
import 'package:guide_app/theme/app_theme.dart';
import 'package:guide_app/widgets/note_widget.dart';
import 'package:guide_app/widgets/bottom_nav_bar.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  List<Map<String, dynamic>> _downloadedChapters = [];
  bool _isLoading = true;
  String _downloadedSize = '0 MB';

  @override
  void initState() {
    super.initState();
    _loadDownloadedChapters();
  }

  Future<void> _loadDownloadedChapters() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // الحصول على قائمة الفصول المحملة
      final chapterIds = await DownloadService.getDownloadedChapters();
      final chapters = <Map<String, dynamic>>[];

      // الحصول على بيانات كل فصل
      for (final chapterId in chapterIds) {
        final chapterData = await DownloadService.getDownloadedChapterData(chapterId);
        if (chapterData != null) {
          chapters.add(chapterData);
        }
      }

      // الحصول على حجم المحتوى المحمل
      final size = await DownloadService.getDownloadedContentSize();

      if (!mounted) return;

      setState(() {
        _downloadedChapters = chapters;
        _downloadedSize = size;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteChapter(String chapterId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الفصل'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الفصل من التنزيلات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final success = await DownloadService.deleteDownloadedChapter(chapterId);

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الفصل بنجاح')),
          );
          _loadDownloadedChapters();
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ أثناء حذف الفصل')),
          );
        }
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء حذف الفصل: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _clearAllDownloads() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع التنزيلات'),
        content: const Text('هل أنت متأكد من رغبتك في مسح جميع المحتوى المحمل؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final success = await DownloadService.clearAllDownloads();

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم مسح جميع التنزيلات بنجاح')),
          );
          _loadDownloadedChapters();
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ أثناء مسح التنزيلات')),
          );
        }
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء مسح التنزيلات: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحتوى المحمل'),
        actions: [
          if (_downloadedChapters.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllDownloads,
              tooltip: 'مسح جميع التنزيلات',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloadedChapters.isEmpty
              ? _buildEmptyState()
              : _buildDownloadsList(),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.download_done_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد محتوى محمل',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'قم بتنزيل الفصول لاستخدامها بدون اتصال بالإنترنت',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/chapters'),
            icon: const Icon(Icons.book),
            label: const Text('استعراض الفصول'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: NoteWidget(
            content: 'المساحة المستخدمة: $_downloadedSize',
            type: NoteType.info,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: _downloadedChapters.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final chapter = _downloadedChapters[index];
              final chapterId = chapter['id'] as String;
              final title = chapter['title'] as String;
              final description = chapter['description'] as String;
              final lessons = chapter['lessons'] as List<dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.book, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteChapter(chapterId),
                            tooltip: 'حذف التنزيل',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${lessons.length} درس',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => context.push('/chapter/$chapterId'),
                            icon: const Icon(Icons.visibility),
                            label: const Text('عرض الفصل'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}