import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guide_app/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    // في التطبيق الحقيقي، سنقوم بالبحث في قاعدة البيانات
    setState(() {
      _isSearching = true;
    });

    // محاكاة تأخير البحث
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      final results = [
        {
          'type': 'lesson',
          'id': 'lesson1',
          'title': 'مقدمة في التطبيق',
          'chapterTitle': 'الفصل الأول: أساسيات التطبيق',
        },
        {
          'type': 'lesson',
          'id': 'lesson2',
          'title': 'إنشاء حساب جديد',
          'chapterTitle': 'الفصل الأول: أساسيات التطبيق',
        },
        {
          'type': 'chapter',
          'id': 'chapter1',
          'title': 'أساسيات التطبيق',
          'description': 'تعلم أساسيات استخدام التطبيق والتنقل بين الشاشات',
        },
      ].where((item) {
        final title = item['title'] as String;
        return title.contains(query);
      }).toList();

      setState(() {
        _isSearching = false;
        _searchResults = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن دروس، فصول...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد نتائج للبحث',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.secondaryTextColor,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : _searchController.text.isEmpty
                        ? _buildSearchSuggestions()
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return _buildSearchResultItem(result);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اقتراحات البحث',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildSearchChip('مقدمة'),
              _buildSearchChip('تسجيل الدخول'),
              _buildSearchChip('الإعدادات'),
              _buildSearchChip('البحث'),
              _buildSearchChip('الاختبارات'),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'آخر عمليات البحث',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('أساسيات التطبيق'),
            onTap: () {
              _searchController.text = 'أساسيات التطبيق';
              _performSearch(_searchController.text);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('كيفية إنشاء حساب'),
            onTap: () {
              _searchController.text = 'كيفية إنشاء حساب';
              _performSearch(_searchController.text);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
        _performSearch(label);
      },
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> result) {
    final type = result['type'] as String;
    final id = result['id'] as String;
    final title = result['title'] as String;

    if (type == 'lesson') {
      final chapterTitle = result['chapterTitle'] as String;
      return ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.article),
        ),
        title: Text(title),
        subtitle: Text(chapterTitle),
        onTap: () => context.push('/lesson/$id'),
      );
    } else if (type == 'chapter') {
      final description = result['description'] as String;
      return ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.book),
        ),
        title: Text(title),
        subtitle: Text(description),
        onTap: () => context.push('/chapter/$id'),
      );
    }

    return const SizedBox.shrink();
  }
}