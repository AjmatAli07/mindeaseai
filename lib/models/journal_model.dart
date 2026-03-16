class JournalEntry {
  final String id;
  final String content;
  final String? mood;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.content,
    this.mood,
    required this.createdAt,
  });

  // ===============================
  // ✅ SAFE FROM SUPABASE MAP
  // ===============================
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      mood: map['mood']?.toString(),
      createdAt: _parseDate(map['created_at']),
    );
  }

  // ===============================
  // 🔐 SAFE DATE PARSER
  // ===============================
  static DateTime _parseDate(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  // ===============================
  // 📤 TO SUPABASE MAP
  // ===============================
  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'content': content,
      'mood': mood,
    };
  }
}
