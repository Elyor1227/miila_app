import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Backend'dan kelgan xato — foydalanuvchiga ko'rsatiladigan xabar bilan
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;

  ApiException(this.message, this.statusCode, [this.code]);

  @override
  String toString() => message;
}

/// Porla/Miila backend bilan ishlash uchun yagona HTTP mijoz.
/// Token SharedPreferences'da saqlanadi; 401 da refresh token orqali
/// bir marta yangilashga urinadi.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://porla-backend-cg4r.onrender.com/api',
  );

  static const _tokenKey = 'auth_token';
  static const _refreshKey = 'refresh_token';

  String? _token;
  String? _refreshToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _refreshToken = prefs.getString(_refreshKey);
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;
  String? get token => _token;

  Future<void> saveTokens(String token, String? refreshToken) async {
    _token = token;
    if (refreshToken != null) _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (refreshToken != null) await prefs.setString(_refreshKey, refreshToken);
  }

  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
  }

  Map<String, String> _headers({bool auth = true}) => {
        'Content-Type': 'application/json',
        if (auth && _token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) =>
      _send('GET', path, auth: auth);

  Future<Map<String, dynamic>> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<Map<String, dynamic>> patch(String path, {Object? body, bool auth = true}) =>
      _send('PATCH', path, body: body, auth: auth);

  Future<Map<String, dynamic>> delete(String path, {Object? body, bool auth = true}) =>
      _send('DELETE', path, body: body, auth: auth);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    bool auth = true,
    bool retried = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    late http.Response res;
    try {
      final request = http.Request(method, uri);
      request.headers.addAll(_headers(auth: auth));
      if (body != null) request.body = jsonEncode(body);
      final streamed = await request.send().timeout(const Duration(seconds: 20));
      res = await http.Response.fromStream(streamed);
    } catch (_) {
      throw ApiException('Server bilan aloqa yo\'q. Internetni tekshiring', 0);
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      data = {};
    }

    if (res.statusCode == 401 && auth && !retried && _refreshToken != null) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        return _send(method, path, body: body, auth: auth, retried: true);
      }
    }

    if (res.statusCode >= 400 || data['success'] == false) {
      throw ApiException(
        (data['message'] as String?) ?? 'Xatolik yuz berdi',
        res.statusCode,
        data['code'] as String?,
      );
    }

    return data;
  }

  Future<bool> _tryRefresh() async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['token'] != null) {
        await saveTokens(data['token'] as String, null);
        return true;
      }
    } catch (_) {}
    await clearTokens();
    return false;
  }
}
