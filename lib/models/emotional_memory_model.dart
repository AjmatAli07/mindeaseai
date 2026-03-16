class EmotionalMemory {
  final String emotion;
  final String source;
  final DateTime createdAt;

  EmotionalMemory({
    required this.emotion,
    required this.source,
    required this.createdAt,
  });

  factory EmotionalMemory.fromMap(Map<String, dynamic> map) {
    return EmotionalMemory(
      emotion: map['emotion'] ?? '',
      source: map['source'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}