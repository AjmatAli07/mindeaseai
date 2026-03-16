import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // =========================
  // 🔐 SIGN UP
  // =========================
  static Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception("Signup failed. Please try again.");
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception("Something went wrong. Try again later.");
    }
  }

  // =========================
  // 🔑 SIGN IN
  // =========================
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        throw Exception("Invalid email or password");
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception("Unable to login. Check your connection.");
    }
  }

  // =========================
  // 🚪 SIGN OUT (ULTRA SAFE)
  // =========================
  static Future<void> signOut() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _supabase.auth.signOut();
      }
    } catch (_) {
      // swallow error → AuthGate will still rebuild
    }
  }

  // =========================
  // 👤 CURRENT USER
  // =========================
  static User? get currentUser {
    return _supabase.auth.currentUser;
  }

  // =========================
  // ✅ LOGIN STATUS
  // =========================
  static bool get isLoggedIn {
    return currentUser != null;
  }
}
