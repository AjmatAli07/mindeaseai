import 'package:flutter/material.dart';
import '../services/checkup_service.dart';

class ResultScreen extends StatelessWidget {
  final int score;

  const ResultScreen({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String resultText = CheckupService.getResult(score);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎯 Simple interpretation logic (UI only)
    IconData icon;
    Color color;
    String level;

    if (score <= 10) {
      level = "Low Stress";
      icon = Icons.sentiment_satisfied_alt;
      color = Colors.green;
    } else if (score <= 20) {
      level = "Moderate Stress";
      icon = Icons.sentiment_neutral;
      color = Colors.orange;
    } else {
      level = "High Stress";
      icon = Icons.sentiment_dissatisfied;
      color = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Check-up Result"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 😊 Result Icon
            Icon(
              icon,
              size: 90,
              color: color,
            ),

            const SizedBox(height: 20),

            // 📊 Stress Level
            Text(
              level,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 10),

            // 🔢 Score
            Text(
              "Your Score: $score",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),

            // 🧠 Result Explanation Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  resultText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🔙 Back Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Home"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
