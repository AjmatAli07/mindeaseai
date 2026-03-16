import 'package:intl/intl.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 🕒 Formatted time (e.g. 10:45 AM)
  String get formattedTime {
    return DateFormat('hh:mm a').format(timestamp);
  }

  /// 📅 Formatted date (e.g. 16 Sep 2025)
  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(timestamp);
  }
}
