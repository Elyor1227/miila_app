import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

/// M-14 — Profilni tahrirlash (real PATCH /auth/update-profile,
/// /auth/update-phone, /auth/change-password'ga ulangan)
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authService = AuthService();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      final currentUser = auth.user;
      final newName = _nameController.text.trim();
      final newPhone = _phoneController.text.trim();
      if (currentUser != null && newName != currentUser.name) {
        await _authService.updateProfile(name: newName);
      }
      if (currentUser != null && newPhone != currentUser.phone && newPhone.isNotEmpty) {
        await _authService.updatePhone(newPhone);
      }
      await auth.refreshMe();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showChangePasswordSheet() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    bool loading = false;
    String? error;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.blush,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Parolni o\'zgartirish', style: AppTextStyles.h4),
                  const SizedBox(height: 18),
                  AppTextField(label: 'Joriy parol', hint: '••••••••', obscureText: true, controller: currentController),
                  const SizedBox(height: 14),
                  AppTextField(label: 'Yangi parol', hint: '••••••••', obscureText: true, controller: newController),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Yangilash',
                    showArrow: false,
                    isLoading: loading,
                    onPressed: () async {
                      if (currentController.text.isEmpty || newController.text.isEmpty) {
                        setSheetState(() => error = 'Ikkala maydonni ham to\'ldiring');
                        return;
                      }
                      setSheetState(() {
                        loading = true;
                        error = null;
                      });
                      try {
                        await _authService.changePassword(
                          currentPassword: currentController.text,
                          newPassword: newController.text,
                        );
                        if (context.mounted) Navigator.of(sheetContext).pop();
                      } catch (e) {
                        setSheetState(() {
                          error = e.toString();
                          loading = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final initial = user?.initial ?? '?';

    return Scaffold(
      backgroundColor: AppColors.blush,
      appBar: AppBar(title: Text('Profilni tahrirlash', style: AppTextStyles.h4)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(initial, style: AppTextStyles.h1.copyWith(color: Colors.white)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blush, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, size: 14, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppTextField(label: 'Ism va familiya', hint: 'Ismingiz', controller: _nameController),
              const SizedBox(height: 18),
              // Email o'zgartirish uchun backend endpoint mavjud emas — faqat ko'rsatiladi
              AppTextField(
                label: 'Email',
                hint: user?.email ?? '',
                keyboardType: TextInputType.emailAddress,
                suffixIcon: const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Telefon raqami',
                hint: '+998 90 123 45 67',
                keyboardType: TextInputType.phone,
                controller: _phoneController,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showChangePasswordSheet,
                child: Text('Parolni o\'zgartirish', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.pink)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: AppTextStyles.caption.copyWith(color: Colors.red)),
              ],
              const SizedBox(height: 32),
              PrimaryButton(label: 'Saqlash', showArrow: false, isLoading: _saving, onPressed: _save),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/delete-data'),
                  child: const Text(
                    'Hisobni o\'chirish',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
