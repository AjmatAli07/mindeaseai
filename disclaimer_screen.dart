import 'package:flutter/material.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disclaimer"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⚠️ Warning Icon
            Center(
              child: Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 24),

            // 🧠 Title
            const Text(
              "Important Information",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 📄 Disclaimer Text
            const Text(
              "MindEaseAI is designed to provide general emotional support and mental well-being guidance for students.\n\n"
              "This application is NOT a substitute for professional medical advice, diagnosis, or treatment.\n\n"
              "If you are experiencing severe emotional distress, suicidal thoughts, or feel unsafe, please seek immediate help from a qualified mental health professional or contact emergency services.\n\n"
              "By using this app, you acknowledge that the information provided is for educational and support purposes only.",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const Spacer(),

            // 🔙 Back Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("I Understand"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
