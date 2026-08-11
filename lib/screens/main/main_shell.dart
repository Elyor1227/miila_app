import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'lessons_screen.dart';

/// Pastki navigatsiya bilan asosiy ilova qatlami:
/// Bosh sahifa / Darslar / Kalendar / Profil
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    LessonsScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  final _items = const [
    {'icon': Icons.home_rounded, 'label': 'Bosh sahifa'},
    {'icon': Icons.menu_book_rounded, 'label': 'Darslar'},
    {'icon': Icons.calendar_month_rounded, 'label': 'Kalendar'},
    {'icon': Icons.person_rounded, 'label': 'Profil'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final selected = i == _index;
                return InkWell(
                  onTap: () => setState(() => _index = i),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _items[i]['icon'] as IconData,
                          color: selected ? AppColors.pink : AppColors.muted,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? AppColors.pink : AppColors.muted,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
