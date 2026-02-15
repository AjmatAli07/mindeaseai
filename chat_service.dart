import 'dart:convert';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // =========================================================
  // 🌐 BACKEND HOST DETECTION
  // =========================================================
  static String get _host {
    if (kIsWeb) return '127.0.0.1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2'; // Android Emulator
    }
    return '127.0.0.1'; // Windows / macOS / iOS
  }

  static Uri get _chatUri => Uri.parse('http://$_host:5000/chat');
  static Uri get _resetUri => Uri.parse('http://$_host:5000/reset');

  // =========================================================
  // 🔹 SEND TEXT MESSAGE (WITH RETRY FIX)
  // =========================================================
  static Future<String> sendMessage(String message) async {
    final user = _supabase.auth.currentUser;
    final bool hasUser = user != null;

    // 🔹 Save user message (non-blocking)
    if (hasUser) {
      try {
        await _supabase.from('chat_messages').insert({
          'user_id': user!.id,
          'role': 'user',
          'message': message,
        });
      } catch (_) {}
    }

    // 🔁 RETRY LOGIC (FIXES RANDOM FAILURES)
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http
            .post(
              _chatUri,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"message": message}),
            )
            .timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final String aiReply =
              (data is Map && data["reply"] != null)
                  ? data["reply"]
                  : _errorMessage();

          // 🔹 Save AI reply (non-blocking)
          if (hasUser) {
            try {
              await _supabase.from('chat_messages').insert({
                'user_id': user.id,
                'role': 'ai',
                'message': aiReply,
              });
            } catch (_) {}
          }

          return aiReply;
        }
      } catch (_) {
        // wait before retry
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
            const Duration(seconds: 10),
          );
    } catch (_) {}
  }

  // =========================================================
  // 🔹 ERROR MESSAGE
  // =========================================================
  static String _errorMessage() {
    return "I'm having trouble connecting right now. Please try again.";
  }
}
