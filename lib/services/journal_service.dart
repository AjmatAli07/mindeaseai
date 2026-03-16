import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_model.dart';
import 'streak_service.dart';
import 'emotional_memory_service.dart'; // ✅ MISSING IMPORT FIXED

class JournalService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ===============================
  // ✍️ ADD NEW JOURNAL ENTRY (SAFE)
  // ===============================
  static Future<void> addJournalEntry({
    required String content,
    String? mood,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final trimmed = content.trim();
      if (trimmed.isEmpty) return;

      // ✅ SAVE JOURNAL
      await _supabase.from('journals').insert({
        'user_id': user.id,
        'content': trimmed,
        'mood': mood,
      });

      // 🧠 SAVE EMOTIONAL MEMORY (FROM JOURNAL)
      EmotionalMemoryService.saveEmotion(
        emotion: mood ?? 'neutral',
        source: 'journal',
      );

      // 🔥 UPDATE STREAK (USER ACTIVITY)
      StreakService.updateStreak();
    } catch (e) {
      print("❌ addJournalEntry error: $e");
    }
  }

  // ===============================
  // 📚 FETCH JOURNAL ENTRIES (SAFE)
  // ===============================
  static Future<List<JournalEntry>> fetchJournals() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('journals')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => JournalEntry.fromMap(e))
          .toList();
    } catch (e) {
      print("❌ fetchJournals error: $e");
      return [];
    }
  }

  // ===============================
  // ✏️ UPDATE JOURNAL ENTRY (SAFE)
  // ===============================
  static Future<void> updateJournalEntry({
    required String id,
    required String content,
    String? mood,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final trimmed = content.trim();
      if (trimmed.isEmpty) return;

      await _supabase
          .from('journals')
          .update({
            'content': trimmed,
            'mood': mood,
          })
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      print("❌ updateJournalEntry error: $e");
    }
  }

  // ===============================
  // 🗑 DELETE JOURNAL ENTRY (SAFE)
  // ===============================
  static Future<void> deleteJournalEntry(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('journals')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      print("❌ deleteJournalEntry error: $e");
    }
  }
}