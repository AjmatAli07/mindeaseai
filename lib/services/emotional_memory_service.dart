import 'package:supabase_flutter/supabase_flutter.dart';

class EmotionalMemoryService {
  static final _supabase = Supabase.instance.client;

  /// 💾 SAVE EMOTION
  static Future<void> saveEmotion({
    required String emotion,
    required String source,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('emotional_memory').insert({
      'user_id': user.id,
      'emotion': emotion,
      'source': source,
    });
  }

  /// 📊 FETCH LAST 30 EMOTIONS
  static Future<List<Map<String, dynamic>>> fetchRecent() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final res = await _supabase
        .from('emotional_memory')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(30);

    return List<Map<String, dynamic>>.from(res);
  }
}