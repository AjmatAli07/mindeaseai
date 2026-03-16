import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'streak_service.dart';
import 'emotional_memory_service.dart';

class ChatService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // =========================================================
  // 🌐 BACKEND URL (RENDER - FREE)
  // =========================================================
  static const String _baseUrl = 'https://mindeaseai.onrender.com';

  static Uri get _chatUri => Uri.parse('$_baseUrl/chat');
  static Uri get _healthUri => Uri.parse('$_baseUrl'); // warm-up ping
  static Uri get _resetUri => Uri.parse('$_baseUrl/reset');

  static bool _backendWarmedUp = false;

  // =========================================================
  // 🔥 BACKEND WARM-UP (FREE FIX)
  // =========================================================
  static Future<void> _warmUpBackend() async {
    if (_backendWarmedUp) return;

    try {
      await http
          .get(_healthUri)
          .timeout(const Duration(seconds: 5));
      _backendWarmedUp = true;
    } catch (_) {
      // ignore – real request will retry
    }
  }

  // =========================================================
  // 🔹 SEND MESSAGE (STABLE + FREE)
  // =========================================================
  static Future<String> sendMessage(String message) async {
    final user = _supabase.auth.currentUser;

    // 🔥 Warm up backend BEFORE sending message
    await _warmUpBackend();

    // 🔥 Update streak (safe)
    StreakService.updateStreak();

    // 🔹 Save user message (fire & forget)
    if (user != null) {
      _supabase.from('chat_messages').insert({
        'user_id': user.id,
        'role': 'user',
        'message': message,
      }).catchError((_) {});
    }

    // 🔁 Retry logic (stable)
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http
            .post(
              _chatUri,
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({'message': message}),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode != 200) {
          throw Exception('Bad status');
        }

        final decoded = utf8.decode(response.bodyBytes);
        if (!decoded.trim().startsWith('{')) {
          throw Exception('Invalid JSON');
        }

        final Map<String, dynamic> data = jsonDecode(decoded);
        final String aiReply =
            data['reply']?.toString().trim() ?? _errorMessage();

        // 🔹 Save AI message
        if (user != null) {
          _supabase.from('chat_messages').insert({
            'user_id': user.id,
            'role': 'ai',
            'message': aiReply,
          }).catchError((_) {});
        }

        // 🧠 Save emotional memory
        await EmotionalMemoryService.saveEmotion(
          emotion: _detectEmotion(aiReply),
          source: 'chat',
        );

        return aiReply;
      } catch (_) {
        // small delay before retry
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    return _errorMessage();
  }

  // =========================================================
  // 🔹 FETCH CHAT HISTORY
  // =========================================================
  static Future<List<Map<String, dynamic>>> fetchChatHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  // =========================================================
  // 🔹 RESET BACKEND MEMORY
  // =========================================================
  static Future<void> resetChat() async {
    try {
      await http.post(_resetUri).timeout(
            const Duration(seconds: 8),
          );
    } catch (_) {}
  }

  // =========================================================
  // 🧠 SIMPLE EMOTION DETECTOR (LOCAL)
  // =========================================================
  static String _detectEmotion(String text) {
    final t = text.toLowerCase();

    if (t.contains('sad') || t.contains('sorry') || t.contains('hurt')) {
      return 'sad';
    }
    if (t.contains('stress') || t.contains('anxious') || t.contains('worry')) {
      return 'anxious';
    }
    if (t.contains('happy') || t.contains('great') || t.contains('glad')) {
      return 'happy';
    }
    if (t.contains('calm') || t.contains('relax') || t.contains('breathe')) {
      return 'calm';
    }

    return 'neutral';
  }

  // =========================================================
  // 🔹 FALLBACK MESSAGE
  // =========================================================
  static String _errorMessage() {
    return "I'm here with you, but I'm having trouble responding right now.";
  }
}