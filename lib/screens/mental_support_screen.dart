import 'package:flutter/material.dart';
import '../services/maps_redirect_service.dart';

class MentalSupportScreen extends StatelessWidget {
  const MentalSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mental Health Support"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_hospital,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),

            const Text(
              "Find Nearby Mental Health Professionals",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "This will open Google Maps to show psychiatrists and mental hospitals near your location.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("Open Google Maps"),
              onPressed: () {
                MapsRedirectService.openMentalHealthSupport();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}