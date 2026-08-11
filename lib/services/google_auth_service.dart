import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Google'dan olingan hisob ma'lumotlari — backendga yuboriladi
class GoogleCredentials {
  final String? idToken;
  final String? accessToken;
  const GoogleCredentials({this.idToken, this.accessToken});

  bool get isEmpty => idToken == null && accessToken == null;
}

/// Google Sign-In oqimi.
///
/// GOOGLE_CLIENT_ID --dart-define orqali berilsa — haqiqiy Google oynasi
/// (mobil: idToken, web: accessToken). Berilmasa — DEV rejim: email/ism
/// so'raladigan dialog va imzosiz idToken (backend DEV rejimda qabul qiladi).
class GoogleAuthService {
  static const String clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

  static bool get isConfigured => clientId.isNotEmpty;

  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _client => _googleSignIn ??= GoogleSignIn(
        clientId: kIsWeb ? clientId : null,
        serverClientId: kIsWeb ? null : clientId,
        scopes: const ['email', 'profile'],
      );

  /// null qaytsa — foydalanuvchi bekor qildi
  Future<GoogleCredentials?> signIn(BuildContext context) async {
    if (!isConfigured) {
      return _devSignIn(context);
    }

    final account = await _client.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    // Mobil: idToken bor; Web: ko'pincha faqat accessToken
    return GoogleCredentials(idToken: auth.idToken, accessToken: auth.accessToken);
  }

  Future<void> signOut() async {
    if (isConfigured) {
      await _client.signOut().catchError((_) => null);
    }
  }

  // ── DEV rejim: Google oynasi simulyatsiyasi ──

  Future<GoogleCredentials?> _devSignIn(BuildContext context) async {
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<GoogleCredentials>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.g_mobiledata_rounded, size: 30, color: Color(0xFF4285F4)),
            const SizedBox(width: 6),
            Expanded(child: Text('Google bilan kirish', style: AppTextStyles.h4)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'DEV rejim: GOOGLE_CLIENT_ID sozlanmagan — Google oynasi simulyatsiya qilinadi',
                style: AppTextStyles.caption.copyWith(color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Gmail manzilingiz'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Ismingiz'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim().toLowerCase();
              final name = nameController.text.trim();
              if (!email.contains('@')) return;
              Navigator.of(dialogContext).pop(
                GoogleCredentials(
                  idToken: _buildUnsignedToken(
                    email: email,
                    name: name.isEmpty ? email.split('@').first : name,
                  ),
                ),
              );
            },
            child: const Text('Davom etish'),
          ),
        ],
      ),
    );

    emailController.dispose();
    nameController.dispose();
    return result;
  }

  /// Imzosiz JWT ({alg: none}) — faqat DEV rejim uchun
  String _buildUnsignedToken({required String email, required String name}) {
    String b64(Map<String, dynamic> json) =>
        base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

    final header = b64({'alg': 'none', 'typ': 'JWT'});
    final payload = b64({
      'sub': 'dev-google-${email.hashCode.toRadixString(16)}',
      'email': email,
      'name': name,
      'picture': '',
      'email_verified': true,
    });
    return '$header.$payload.';
  }
}
