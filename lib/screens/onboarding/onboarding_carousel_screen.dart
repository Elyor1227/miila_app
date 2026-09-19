import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/onboarding_scaffold.dart';
import '../../widgets/primary_button.dart';

class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLogo;
  const _Slide({required this.icon, required this.title, required this.subtitle, this.isLogo = false});
}

/// R-02, R-03, R-04 — uchta tanishtiruv slaydi bitta PageView ichida
class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() => _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_Slide> _slides = const [
    _Slide(
      icon: Icons.favorite,
      isLogo: true,
      title: 'O\'z tanangizni anglang',
      subtitle: 'Siklingizni kuzatib va salomatligingiz haqida ko\'proq bilib oling',
    ),
    _Slide(
      icon: Icons.calendar_month_rounded,
      title: 'Siklingizni oson kuzating',
      subtitle: 'Hayz, ovulyatsiya va fertil kunlaringizni aniq va oson kuzatib boring',
    ),
    _Slide(
      icon: Icons.play_circle_fill_rounded,
      title: 'Qisqa darslar',
      subtitle: 'Reproduktiv salomatlik haqida qisqa va foydali video darslarni tomosha qiling',
    ),
  ];

  void _next() {
    if (_index == _slides.length - 1) {
      Navigator.of(context).pushNamed('/login');
    } else {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;
    return OnboardingScaffold(
      showBack: false,
      skipLabel: 'Hisobga kirish',
      onSkip: () => Navigator.of(context).pushNamed('/login'),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PageDots(count: _slides.length, activeIndex: _index),
          const SizedBox(height: 20),
          PrimaryButton(
            label: isLast ? 'Boshlash' : 'Keyingi',
            onPressed: _next,
          ),
        ],
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: PageView.builder(
          controller: _controller,
          itemCount: _slides.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            final slide = _slides[i];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.pink, AppColors.deep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(slide.icon, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 16),
                if (slide.isLogo) Text('Miila', style: AppTextStyles.logo),
                const SizedBox(height: 28),
                Text(slide.title, textAlign: TextAlign.center, style: AppTextStyles.h2),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(slide.subtitle, textAlign: TextAlign.center, style: AppTextStyles.body),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
