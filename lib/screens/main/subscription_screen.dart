import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/payment_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/settings_tile.dart';

/// M-21 — Obuna boshqaruvi (real /payments API'larga ulangan)
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _service = PaymentService();
  SubscriptionInfo? _info;
  List<PaymentRecord> _history = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.getSubscription(),
        _service.getHistory(),
      ]);
      if (!mounted) return;
      setState(() {
        _info = results[0] as SubscriptionInfo;
        _history = results[1] as List<PaymentRecord>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _fmtDate(DateTime? d) => d == null ? '—' : DateFormat('d-MMM yyyy', 'uz').format(d);
  String _fmtAmount(int? a) =>
      a == null ? '—' : '${NumberFormat('#,###', 'uz').format(a).replaceAll(',', ' ')} so\'m';

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Obunani bekor qilish', style: AppTextStyles.h4),
        content: Text(
          'Premium imkoniyatlar joriy davr oxirigacha ishlayveradi. Bekor qilasizmi?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Yo\'q'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ha, bekor qilish', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.cancelSubscription();
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.blush,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To\'lovlar tarixi', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              Text('Hozircha to\'lovlar yo\'q', style: AppTextStyles.body)
            else
              ..._history.take(8).map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          p.status == 'paid'
                              ? Icons.check_circle_rounded
                              : p.status == 'pending'
                                  ? Icons.schedule_rounded
                                  : Icons.cancel_rounded,
                          size: 18,
                          color: p.status == 'paid'
                              ? AppColors.success
                              : p.status == 'pending'
                                  ? AppColors.gold
                                  : Colors.redAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p.planLabel} · ${p.provider}', style: AppTextStyles.bodyMedium),
                              Text(_fmtDate(p.paidAt ?? p.createdAt), style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Text(_fmtAmount(p.amount), style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Obuna boshqaruvi', style: AppTextStyles.h4)),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.pink))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _load,
                color: AppColors.pink,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    // Sarlavha kartasi
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.goldGradient),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Miila Premium',
                                        style: TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                                    Text(
                                      _info?.isPro == true
                                          ? '${_info?.planLabel ?? ''} tarif'
                                          : 'Obuna mavjud emas',
                                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _info?.isPro == true ? '● Faol' : 'Nofaol',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          if (_info?.isPro == true) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _info?.cancelled == true ? 'Tugash sanasi' : 'Keyingi to\'lov',
                                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                                ),
                                Text(
                                  '${_fmtDate(_info?.proExpiresAt)} · ${_fmtAmount(_info?.amount)}',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text('BOSHQARUV', style: AppTextStyles.label),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: [
                          SettingsTile(
                            icon: Icons.swap_horiz_rounded,
                            title: 'Tarifni o\'zgartirish',
                            subtitle: _info?.planLabel ?? '—',
                            onTap: () => Navigator.of(context)
                                .pushNamed('/payment')
                                .then((_) => _load()),
                          ),
                          const Divider(height: 1),
                          SettingsTile(
                            icon: Icons.receipt_long_rounded,
                            title: 'To\'lovlar tarixi',
                            subtitle: '${_history.length} ta to\'lov',
                            onTap: _showHistory,
                          ),
                        ],
                      ),
                    ),
                    if (_info?.isPro == true && _info?.cancelled != true) ...[
                      const SizedBox(height: 18),
                      OutlinedButton(
                        onPressed: _cancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: const Text('Obunani bekor qilish'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
