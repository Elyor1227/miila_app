import 'api_client.dart';

/// /auth endpointlari: profil, OTP, parol tiklash, PIN, maxfiylik,
/// sessiyalar, ma'lumot eksporti va hisobni o'chirish.
class AuthService {
  final _api = ApiClient.instance;

  // ── Profil ──

  Future<Map<String, dynamic>> updateProfile({String? name, String? avatar, DateTime? birthDate}) async {
    final data = await _api.patch('/auth/update-profile', body: {
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
    });
    return data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePhone(String phone) async {
    final data = await _api.patch('/auth/update-phone', body: {'phone': phone});
    return data['user'] as Map<String, dynamic>;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.patch('/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // ── Telefon OTP ──

  Future<void> sendOtp(String phone) async {
    await _api.post('/auth/otp/send', auth: false, body: {'phone': phone});
  }

  Future<String> verifyOtp(String phone, String code) async {
    final data = await _api.post('/auth/otp/verify', auth: false, body: {
      'phone': phone,
      'code': code,
    });
    return (data['data'] as Map<String, dynamic>)['phoneVerifyToken'] as String;
  }

  // ── Parolni tiklash ──

  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', auth: false, body: {'email': email});
  }

  // ── PIN-kod va xavfsizlik ──

  Future<Map<String, dynamic>> setPin(String pin) async {
    final data = await _api.patch('/auth/pin', body: {'pin': pin});
    return data['user'] as Map<String, dynamic>;
  }

  Future<bool> verifyPin(String pin) async {
    await _api.post('/auth/pin/verify', body: {'pin': pin});
    return true;
  }

  Future<Map<String, dynamic>> disablePin() async {
    final data = await _api.delete('/auth/pin');
    return data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSecuritySettings({
    bool? biometricEnabled,
    int? autoLockMinutes,
  }) async {
    final data = await _api.patch('/auth/security-settings', body: {
      if (biometricEnabled != null) 'biometricEnabled': biometricEnabled,
      if (autoLockMinutes != null) 'autoLockMinutes': autoLockMinutes,
    });
    return data['user'] as Map<String, dynamic>;
  }

  // ── Maxfiylik ──

  Future<Map<String, dynamic>> updatePrivacySettings({
    bool? anonymousMode,
    bool? shareAnalytics,
  }) async {
    final data = await _api.patch('/auth/privacy-settings', body: {
      if (anonymousMode != null) 'anonymousMode': anonymousMode,
      if (shareAnalytics != null) 'shareAnalytics': shareAnalytics,
    });
    return data['user'] as Map<String, dynamic>;
  }

  // ── Bildirishnoma sozlamalari ──

  Future<Map<String, dynamic>> updateNotificationSettings(Map<String, bool> settings) async {
    final data = await _api.patch('/auth/notification-settings', body: settings);
    return data['user'] as Map<String, dynamic>;
  }

  // ── Faol sessiyalar ──

  Future<List<Map<String, dynamic>>> getSessions() async {
    final data = await _api.get('/auth/sessions');
    return (data['sessions'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> revokeSession(String id) async {
    await _api.delete('/auth/sessions/$id');
  }

  // ── Ma'lumotlar ──

  Future<Map<String, dynamic>> exportData() async {
    final data = await _api.get('/auth/export-data');
    return data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteAccount(String password) async {
    await _api.delete('/auth/me', body: {'password': password});
  }
}
