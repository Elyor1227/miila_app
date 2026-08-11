import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_text_field.dart';

/// M-23 — Ma'lumotlarni o'chirish (real DELETE /auth/me'ga ulangan)
class DeleteDataScreen extends StatefulWidget {
  const DeleteDataScreen({super.key});

  @override
  State<DeleteDataScreen> createState() => _DeleteDataScreenState();
}

class _DeleteDataScreenState extends State<DeleteDataScreen> {
  final _authService = AuthService();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  static const _items = [
    (Icons.water_drop_outlined, 'Sikl tarixi va barcha yozuvlar'),
    (Icons.monitor_heart_outlined, 'Belgilar, kayfiyat va tahlillar'),
    (Icons.menu_book_outlined, 'Kurslar progressi va yutuqlar'),
    (Icons.workspace_premium_outlined, 'Premium obuna (agar faol bo\'lsa)'),
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Tasdiqlash uchun parolni kiriting');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.deleteAccount(password);
      if (!mounted) return;
      await context.read<AuthProvider>().onAccountDeleted();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/language', (r) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Ma\'lumotlarni o\'chirish', style: AppTextStyles.h4)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 34),
                ),
              ),
              const SizedBox(height: 18),
              Center(child: Text('Hisobni o\'chirmoqchimisiz?', style: AppTextStyles.h3)),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Bu amalni qaytarib bo\'lmaydi. Quyidagilar butunlay o\'chiriladi:',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _items.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Icon(_items[i].$1, color: AppColors.pink, size: 20),
                        title: Text(_items[i].$2, style: AppTextStyles.bodyMedium),
                        dense: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Parolni kiriting',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    disabledBackgroundColor: Colors.redAccent.withOpacity(0.6),
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 20),
                  label: Text('Hisobni o\'chirish', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text('Bekor qilish', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
