import 'package:flutter/material.dart';
import '../services/checkup_service.dart';
import '../models/question_model.dart';
import 'result_screen.dart';

class CheckupScreen extends StatefulWidget {
  @override
  _CheckupScreenState createState() => _CheckupScreenState();
}

class _CheckupScreenState extends State<CheckupScreen> {
  int currentIndex = 0;
  int totalScore = 0;

  final List<Question> questions = CheckupService.questions;

  void answerQuestion(int score) {
    totalScore += score;

    setState(() {
      currentIndex++;
    });

    if (currentIndex >= questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: totalScore),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mental Health Check-up"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: currentIndex < questions.length
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📊 Progress Indicator
                  Text(
                    "Question ${currentIndex + 1} of ${questions.length}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / questions.length,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[300],
                    color: Theme.of(context).primaryColor,
                  ),

                  const SizedBox(height: 30),

                  // 🧠 Question Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        questions[currentIndex].text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔘 Answer Options
                  ...questions[currentIndex].options
                      .asMap()
                      .entries
                      .map((entry) {
                    int idx = entry.key;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => answerQuestion(
                          questions[currentIndex].scores[idx],
                        ),
                        child: Text(
                          entry.value,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              )
            : const Center(
                child: Text(
                  "Check-up Completed",
                  style: TextStyle(fontSize: 18),
                ),
              ),
      ),
    );
  }
}
