import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/payment_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

/// M-16 — To'lov / Obuna (real /payments/initiate'ga ulangan)
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _service = PaymentService();
  String _plan = 'yearly';
  String _method = 'click';
  bool _loading = false;

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      // "Bank kartasi" ham Click orqali (karta bilan to'lash imkoniyati bor)
      final provider = _method == 'card' ? 'click' : _method;
      final checkoutUrl = await _service.initiate(planKey: _plan, provider: provider);
      if (!mounted) return;

      final uri = Uri.parse(checkoutUrl);
      final launched = await canLaunchUrl(uri) && await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        // DEV/mock URL ochilmasa — foydalanuvchiga ko'rsatamiz
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.white,
            title: Text('To\'lov sahifasi', style: AppTextStyles.h4),
            content: SelectableText(checkoutUrl, style: AppTextStyles.caption),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Yopish')),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _plan == 'yearly' ? '399 000 so\'m' : '49 000 so\'m';
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Obuna', style: AppTextStyles.h4)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Miila Premium banner (Figma M-16)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.goldGradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text('Miila Premium',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('✓  Barcha premium kurslarga to\'liq kirish',
                        style: AppTextStyles.caption.copyWith(color: Colors.white)),
                    Text('✓  Reklama yo\'q · istalgan vaqt bekor qilish',
                        style: AppTextStyles.caption.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('TARIFNI TANLANG', style: AppTextStyles.label),
              const SizedBox(height: 14),
              _planCard(
                id: 'yearly',
                title: 'Yillik',
                price: '399 000',
                badge: '-32%',
                subtitle: '33 250 so\'m/oy',
              ),
              const SizedBox(height: 12),
              _planCard(
                id: 'monthly',
                title: 'Oylik',
                price: '49 000',
                subtitle: 'Har oy yangilanadi',
              ),
              const SizedBox(height: 28),
              Text('TO\'LOV USULI', style: AppTextStyles.label),
              const SizedBox(height: 14),
              _methodTile(
                  id: 'click',
                  title: 'Click',
                  subtitle: 'Telefon yoki karta orqali',
                  icon: Icons.flash_on_rounded,
                  color: const Color(0xFF00AEEF)),
              const SizedBox(height: 10),
              _methodTile(
                  id: 'payme',
                  title: 'Payme',
                  subtitle: 'Telefon raqami orqali',
                  icon: Icons.payment_rounded,
                  color: const Color(0xFF00CDAC)),
              const SizedBox(height: 10),
              _methodTile(
                  id: 'card',
                  title: 'Bank kartasi',
                  subtitle: 'Uzcard · Humo · Visa',
                  icon: Icons.credit_card_rounded,
                  color: AppColors.deep),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jami (${_plan == 'yearly' ? 'yillik' : 'oylik'})', style: AppTextStyles.bodyMedium),
                  Text(total, style: AppTextStyles.h4),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'To\'lash',
                showArrow: false,
                isLoading: _loading,
                color: AppColors.gold,
                onPressed: _pay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planCard({
    required String id,
    required String title,
    required String price,
    required String subtitle,
    String? badge,
  }) {
    final selected = _plan == id;
    return InkWell(
      onTap: () => setState(() => _plan = id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.gold : AppColors.cardBorder, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.gold : AppColors.cardBorder, width: 2),
                color: selected ? AppColors.gold : Colors.transparent,
              ),
              child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTextStyles.bodyMedium),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(badge,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gold, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(price, style: AppTextStyles.h4),
          ],
        ),
      ),
    );
  }

  Widget _methodTile({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final selected = _method == id;
    return InkWell(
      onTap: () => setState(() => _method = id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.pink : AppColors.cardBorder, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.pink : AppColors.cardBorder, width: 2),
                color: selected ? AppColors.pink : Colors.transparent,
              ),
              child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}
