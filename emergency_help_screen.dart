import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHelpScreen extends StatelessWidget {
  const EmergencyHelpScreen({Key? key}) : super(key: key);

  // 📞 Helper method to call a number
  Future<void> _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Help"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🚨 Emergency Icon
            Center(
              child: Icon(
                Icons.health_and_safety,
                size: 90,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 20),

            // 🧠 Heading
            const Text(
              "You Are Not Alone",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // 📄 Description
            const Text(
              "If you are feeling overwhelmed, unsafe, or having thoughts of self-harm, "
              "please reach out for immediate help. Talking to a trained professional can make a difference.\n\n"
              "Below are some emergency helplines available in India:",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // ☎️ Helpline Buttons
            _helplineButton(
              context,
              title: "Kiran (Mental Health Helpline)",
              number: "1800-599-0019",
            ),

            _helplineButton(
              context,
              title: "AASRA",
              number: "91-9820466726",
            ),

            _helplineButton(
              context,
              title: "Sneha Foundation",
              number: "044-24640050",
            ),

            const Spacer(),

            // 🔙 Back Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
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

  // 🔘 Reusable helpline button
  Widget _helplineButton(
    BuildContext context, {
    required String title,
    required String number,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.call),
        label: Text("$title\n$number", textAlign: TextAlign.center),
        onPressed: () => _callNumber(number),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
