import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CrisisAlertScreen extends StatelessWidget {
  const CrisisAlertScreen({super.key});

  // 📞 Open Mental Health Helpline (India)
  Future<void> _openHelpline() async {
    final Uri uri = Uri(scheme: 'tel', path: '9152987821');

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint("❌ Could not launch helpline");
    }
  }

  // 📍 Open Google Maps with nearby mental health support
  Future<void> _openMaps() async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/mental+health+hospital+near+me',
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint("❌ Could not launch maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text("You’re Not Alone"),
        centerTitle: true,
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              "We’ve noticed you might be going through a tough time.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Reaching out for help is a sign of strength.\nSupport is available, and you are not alone.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            // 📞 CALL BUTTON
            ElevatedButton.icon(
              onPressed: _openHelpline,
              icon: const Icon(Icons.call),
              label: const Text("Call Mental Health Helpline"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 📍 MAP BUTTON
            OutlinedButton.icon(
              onPressed: _openMaps,
              icon: const Icon(Icons.location_on),
              label: const Text("Find Nearby Support"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 👈 SAFE EXIT
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("I’m okay for now"),
            ),
          ],
        ),
      ),
    );
  }
}