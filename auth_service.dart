import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔐 Sign up with email & password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// 🔑 Login with email & password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// 🚪 Logout
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// 👤 Get current logged-in user
  static User? get currentUser {
    return _supabase.auth.currentUser;
  }

  /// ✅ Check if user is logged in
  static bool get isLoggedIn {
    return currentUser != null;
  }
}
