import 'package:flutter/material.dart';
import '../services/emotion_trend_service.dart';

class EmotionDashboardScreen extends StatefulWidget {
  const EmotionDashboardScreen({super.key});

  @override
  State<EmotionDashboardScreen> createState() =>
      _EmotionDashboardScreenState();
}

class _EmotionDashboardScreenState extends State<EmotionDashboardScreen> {
  Map<String, int> _emotionCounts = {};
  String _trend = "";
  String _dominant = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  Future<void> _loadTrends() async {
    final emotions = await EmotionTrendService.fetchRecentEmotions();
    final counts = EmotionTrendService.countEmotions(emotions);

    setState(() {
      _emotionCounts = counts;
      _trend = EmotionTrendService.calculateTrend(counts);
      _dominant = EmotionTrendService.dominantEmotion(counts);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emotional Trends"),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoCard("Overall Trend", _trend, Icons.insights),
                  _infoCard(
                      "Dominant Emotion", _dominant, Icons.emoji_emotions),

                  const SizedBox(height: 20),
                  const Text(
                    "Emotion Frequency (Last 7 Days)",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: _emotionCounts.isEmpty
                        ? const Center(child: Text("No emotional data yet"))
                        : ListView(
                            children: _emotionCounts.entries.map((e) {
                              return ListTile(
                                leading: const Icon(Icons.circle, size: 12),
                                title: Text(e.key.toUpperCase()),
                                trailing: Text("${e.value} times"),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}