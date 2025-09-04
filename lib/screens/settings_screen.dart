import 'package:flutter/material.dart';
import 'package:guide_app/theme/app_theme.dart';
import 'package:guide_app/widgets/bottom_nav_bar.dart';
import 'package:guide_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _downloadOverWifi = true;
  String _selectedLanguage = 'العربية';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // في التطبيق الحقيقي، سنقوم بتحميل الإعدادات من SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
        _downloadOverWifi = prefs.getBool('downloadOverWifi') ?? true;
        _selectedLanguage = prefs.getString('language') ?? 'العربية';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الإعدادات: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
      await prefs.setBool('downloadOverWifi', _downloadOverWifi);
      await prefs.setString('language', _selectedLanguage);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ الإعدادات: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'المظهر'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('الوضع الداكن'),
                subtitle: const Text('تفعيل المظهر الداكن للتطبيق'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                  // عرض رسالة تأكيد
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                          ? 'تم تفعيل الوضع الداكن 🌙'
                          : 'تم تفعيل الوضع العادي ☀️',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'اللغة'),
          ListTile(
            title: const Text('لغة التطبيق'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageSelector(context);
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'الإشعارات'),
          SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            subtitle: const Text('استلام إشعارات عن المحتوى الجديد والتحديثات'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                _saveSettings();
              });
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'التنزيلات'),
          SwitchListTile(
            title: const Text('التنزيل عبر WiFi فقط'),
            subtitle: const Text('تنزيل المحتوى فقط عند الاتصال بشبكة WiFi'),
            value: _downloadOverWifi,
            onChanged: (value) {
              setState(() {
                _downloadOverWifi = value;
                _saveSettings();
              });
            },
          ),
          ListTile(
            title: const Text('مسح ذاكرة التخزين المؤقت'),
            subtitle: const Text('0.0 MB'),
            trailing: ElevatedButton(
              onPressed: () {
                _showClearCacheDialog(context);
              },
              child: const Text('مسح'),
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'الحساب'),
          ListTile(
            title: const Text('معلومات الحساب'),
            subtitle: const Text('تعديل معلومات الملف الشخصي'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAccountInfo(context);
            },
          ),
          ListTile(
            title: const Text('تسجيل الخروج'),
            trailing: const Icon(Icons.logout),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'عن التطبيق'),
          ListTile(
            title: const Text('الإصدار'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('سياسة الخصوصية'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // التنقل إلى صفحة سياسة الخصوصية
            },
          ),
          ListTile(
            title: const Text('شروط الاستخدام'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showTermsAndConditions(context);
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر اللغة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('العربية'),
                value: 'العربية',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedLanguage = value;
                    _saveSettings();
                    Navigator.pop(context);
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedLanguage = value;
                    _saveSettings();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('مسح ذاكرة التخزين المؤقت'),
          content: const Text(
              'هل أنت متأكد من رغبتك في مسح ذاكرة التخزين المؤقت؟ سيتم إزالة جميع الملفات المؤقتة.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                // تنفيذ عملية مسح ذاكرة التخزين المؤقت
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم مسح ذاكرة التخزين المؤقت بنجاح'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('مسح'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                // تنفيذ عملية تسجيل الخروج
                Navigator.pop(context);
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات الحساب'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الاسم: مستخدم تجريبي'),
            SizedBox(height: 8),
            Text('البريد الإلكتروني: user@example.com'),
            SizedBox(height: 8),
            Text('تاريخ الانضمام: 2024/01/01'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // هنا يمكن فتح شاشة تعديل المعلومات
            },
            child: const Text('تعديل'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شروط الاستخدام'),
        content: const SingleChildScrollView(
          child: Text(
            'هذه هي شروط استخدام التطبيق. يرجى قراءتها بعناية قبل استخدام التطبيق.\n\n'
            '1. استخدام التطبيق للأغراض التعليمية فقط.\n'
            '2. عدم مشاركة المحتوى بدون إذن.\n'
            '3. احترام حقوق الملكية الفكرية.\n'
            '4. عدم استخدام التطبيق لأغراض غير قانونية.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}