import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// R- va L- oqimlari uchun umumiy qatlam: orqaga tugma (ixtiyoriy),
/// yuqori o'ng burchakda "O'tkazib yuborish" (ixtiyoriy) va pastda
/// asosiy tugma joyi doim ekran pastida turadi.
class OnboardingScaffold extends StatelessWidget {
  final Widget child;
  final bool showBack;
  final String? skipLabel;
  final VoidCallback? onSkip;
  final Widget? bottom;

  const OnboardingScaffold({
    super.key,
    required this.child,
    this.showBack = true,
    this.skipLabel,
    this.onSkip,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      body: SafeArea(
        child: Column(
          children: [
            if (showBack || skipLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showBack)
                      _CircleIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).maybePop(),
                      )
                    else
                      const SizedBox(width: 40),
                    if (skipLabel != null)
                      TextButton(
                        onPressed: onSkip,
                        child: Text(
                          skipLabel!,
                          style: const TextStyle(color: AppColors.muted, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: child,
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: bottom!,
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }
}

/// Onboarding karuselidagi nuqtalar (dots indicator)
class PageDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  const PageDots({super.key, required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.pink : AppColors.cardBorder,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
