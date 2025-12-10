// lib/src/core/services/session_service.dart
class SessionService {
  /// Contient la ligne complète renvoyée par Supabase (table `utilisateur`)
  static Map<String, dynamic>? _currentUser;

  static Map<String, dynamic>? get currentUser => _currentUser;

  static bool get isLoggedIn => _currentUser != null;

  static void setUser(Map<String, dynamic>? user) {
    _currentUser = user;
  }

  static void clear() {
    _currentUser = null;
  }
}
