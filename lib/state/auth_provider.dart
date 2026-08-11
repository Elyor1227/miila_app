import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';

/// Haqiqiy /auth API bilan ishlaydigan autentifikatsiya holati.
class AuthProvider extends ChangeNotifier {
  final _api = ApiClient.instance;

  AppUser? _user;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  /// Splash'da chaqiriladi: saqlangan token bo'lsa /auth/me orqali tiklaydi.
  Future<bool> tryRestoreSession() async {
    await _api.init();
    if (!_api.hasToken) return false;
    try {
      final data = await _api.get('/auth/me');
      _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (_) {
      await _api.clearTokens();
      return false;
    }
  }

  Future<void> login({required String login, required String password}) async {
    final data = await _api.post('/auth/login', auth: false, body: {
      'login': login,
      'password': password,
    });
    await _api.saveTokens(data['token'] as String, data['refreshToken'] as String?);
    _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    notifyListeners();
  }

  /// phoneVerifyToken ixtiyoriy — SMS tasdiqlash keyinroq yoqilganda ishlatiladi
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? phoneVerifyToken,
  }) async {
    final data = await _api.post('/auth/register', auth: false, body: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      if (phoneVerifyToken != null) 'phoneVerifyToken': phoneVerifyToken,
    });
    await _api.saveTokens(data['token'] as String, data['refreshToken'] as String?);
    _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    notifyListeners();
  }

  /// Google orqali kirish — backend hisobni topadi yoki yaratadi.
  /// Qaytadi: telefon hali ulanmagan bo'lsa true (phoneSetupRequired).
  Future<bool> loginWithGoogle({String? idToken, String? accessToken}) async {
    final data = await _api.post('/auth/google', auth: false, body: {
      if (idToken != null) 'idToken': idToken,
      if (accessToken != null) 'accessToken': accessToken,
    });
    await _api.saveTokens(data['token'] as String, data['refreshToken'] as String?);
    _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    notifyListeners();
    return data['phoneSetupRequired'] == true;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Server xatosi logoutga to'sqinlik qilmasin
    }
    await _api.clearTokens();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshMe() async {
    final data = await _api.get('/auth/me');
    _user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    notifyListeners();
  }

  /// Sozlamalar ekranlari PATCH javobidagi yangilangan user'ni shu yerga beradi.
  void applyUser(Map<String, dynamic> userJson) {
    _user = AppUser.fromJson(userJson);
    notifyListeners();
  }

  /// Hisob o'chirilganda lokal holatni tozalaydi.
  Future<void> onAccountDeleted() async {
    await _api.clearTokens();
    _user = null;
    notifyListeners();
  }
}
