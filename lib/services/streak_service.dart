import 'package:supabase_flutter/supabase_flutter.dart';

class StreakService {
  static final SupabaseClient _supabase =
      Supabase.instance.client;

  /// 🔥 UPDATE STREAK (CALL ON CHAT / JOURNAL ACTIVITY)
  static Future<void> updateStreak() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final today =
        DateTime(now.year, now.month, now.day);

    try {
      final response = await _supabase
          .from('streaks')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      // 🆕 First activity ever
      if (response == null) {
        await _supabase.from('streaks').insert({
          'user_id': user.id,
          'current_streak': 1,
          'last_active_date': today.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        return;
      }

      final lastActiveRaw = response['last_active_date'];
      final lastActive = lastActiveRaw == null
          ? null
          : DateTime.tryParse(lastActiveRaw);

      // 🛑 Already counted today
      if (lastActive != null &&
          _isSameDay(lastActive, today)) {
        return;
      }

      int currentStreak =
          response['current_streak'] ?? 0;

      // 🔥 Yesterday → continue streak
      if (lastActive != null &&
          _isYesterday(lastActive, today)) {
        currentStreak += 1;
      } else {
        // ❌ Broken streak → reset
        currentStreak = 1;
      }

      await _supabase.from('streaks').update({
        'current_streak': currentStreak,
        'last_active_date': today.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);
    } catch (e) {
      print('❌ updateStreak error: $e');
    }
  }

  /// 📊 GET CURRENT STREAK (FOR UI)
  static Future<int> getCurrentStreak() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    try {
      final response = await _supabase
          .from('streaks')
          .select('current_streak')
          .eq('user_id', user.id)
          .maybeSingle();

      return response?['current_streak'] ?? 0;
    } catch (e) {
      print('❌ getCurrentStreak error: $e');
      return 0;
    }
  }

  // =========================
  // 🧠 DATE HELPERS
  // =========================
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  static bool _isYesterday(DateTime last, DateTime today) {
    final yesterday =
        today.subtract(const Duration(days: 1));
    return _isSameDay(last, yesterday);
  }
}