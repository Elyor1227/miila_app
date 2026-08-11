import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Hali tayyor bo'lmagan bo'limlar uchun vaqtinchalik qatlam
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.message = 'Bu bo\'lim tez orada tayyor bo\'ladi',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text(title, style: AppTextStyles.h4)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 18),
              Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
