// lib/src/core/services/session_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Map<String, dynamic>? _currentUser;

  static const _userKey = 'current_user';
  static const _expiresKey = 'session_expires_at';

  /// ⏱ Durée de session (14 jours)
  static const Duration sessionDuration = Duration(days: 14);

  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  /// 🔹 Initialisation AU DÉMARRAGE DE L’APP
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = prefs.getString(_userKey);
    final expiresStr = prefs.getString(_expiresKey);

    if (userJson == null || expiresStr == null) {
      clear();
      return;
    }

    final expiresAt = DateTime.tryParse(expiresStr);
    if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
      // ⛔ session expirée
      clear();
      return;
    }

    _currentUser = jsonDecode(userJson);
  }

  /// 🔹 Login (appelé après connexion réussie)
  static Future<void> setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    final expiresAt =
    DateTime.now().add(sessionDuration).toIso8601String();

    _currentUser = user;

    await prefs.setString(_userKey, jsonEncode(user));
    await prefs.setString(_expiresKey, expiresAt);
  }

  /// 🔹 Refresh session (optionnel mais recommandé)
  static Future<void> refreshSession() async {
    if (_currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final newExpires =
    DateTime.now().add(sessionDuration).toIso8601String();

    await prefs.setString(_expiresKey, newExpires);
  }

  /// 🔹 Logout
  static Future<void> clear() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_expiresKey);
  }
}
