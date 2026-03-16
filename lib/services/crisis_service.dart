import 'package:supabase_flutter/supabase_flutter.dart';

class CrisisService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// 🚨 Check if user is in emotional crisis
  static Future<bool> isUserInCrisis({int days = 3}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final since =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();

    try {
      final response = await _supabase
          .from('emotional_memory')
          .select('emotion')
          .eq('user_id', user.id)
          .gte('created_at', since);

      if (response.isEmpty) return false;

      int negativeCount = 0;

      for (final row in response) {
        final emotion = row['emotion'];
        if (emotion == 'sad' ||
            emotion == 'anxious' ||
            emotion == 'stressed') {
          negativeCount++;
        }
      }

      // 🚨 Crisis condition
      return negativeCount >= response.length * 0.7;
    } catch (_) {
      return false;
    }
  }
}