import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'الفصول',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download),
          label: 'التحميلات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'الإعدادات',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) {
              context.go('/');
            }
            break;
          case 1:
            if (currentIndex != 1) {
              context.go('/chapters');
            }
            break;
          case 2:
            if (currentIndex != 2) {
              context.go('/downloads');
            }
            break;
          case 3:
            if (currentIndex != 3) {
              context.go('/settings');
            }
            break;
        }
      },
    );
  }
}
