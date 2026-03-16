import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionTrendService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch emotions from last N days
  static Future<List<String>> fetchRecentEmotions({int days = 7}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();

    try {
      final response = await _supabase
          .from('emotional_memory')
          .select('emotion')
          .eq('user_id', user.id)
          .gte('created_at', since);

      return (response as List)
          .map((e) => e['emotion'].toString())
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Count emotion frequency
  static Map<String, int> countEmotions(List<String> emotions) {
    final Map<String, int> counts = {};
    for (final e in emotions) {
      counts[e] = (counts[e] ?? 0) + 1;
    }
    return counts;
  }

  /// Determine emotional trend
  static String calculateTrend(Map<String, int> counts) {
    const positive = ['happy', 'calm'];
    const negative = ['sad', 'anxious', 'stressed'];

    int positiveScore = 0;
    int negativeScore = 0;

    counts.forEach((emotion, count) {
      if (positive.contains(emotion)) {
        positiveScore += count;
      }
      if (negative.contains(emotion)) {
        negativeScore += count;
      }
    });

    if (positiveScore > negativeScore) return "Improving 🌱";
    if (negativeScore > positiveScore) return "Needs Attention ⚠️";
    return "Stable 🙂";
  }

  /// Get dominant emotion
  static String dominantEmotion(Map<String, int> counts) {
    if (counts.isEmpty) return "No data";

    return counts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}