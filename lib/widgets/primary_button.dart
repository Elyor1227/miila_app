import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Asosiy pushti tugma. Figma'dagi barcha "Davom etish / Boshlash / Kirish"
/// tugmalarida ishlatilgan uslub — to'liq kenglik, 16 radius, ixtiyoriy ok.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool showArrow;
  final bool isLoading;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.showArrow = true,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.pink,
          disabledBackgroundColor: (color ?? AppColors.pink).withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: AppTextStyles.button),
                  if (showArrow) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Ikkinchi darajali tugma (oq fon, chegara bilan) — Google/Apple kabi holatlar uchun.
class SecondaryButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.white,
    this.textColor = AppColors.ink,
    this.borderColor = AppColors.cardBorder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: borderColor != null ? BorderSide(color: borderColor!) : BorderSide.none,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}
