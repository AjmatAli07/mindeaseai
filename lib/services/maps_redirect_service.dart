import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsRedirectService {
  /// 🔍 Open Google Maps with nearby mental health support
  static Future<void> openMentalHealthSupport() async {
    // 1️⃣ Ask location permission
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // 2️⃣ Get current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final lat = position.latitude;
    final lng = position.longitude;

    // 3️⃣ Google Maps search query
    final query = Uri.encodeComponent(
        "psychiatrist OR mental hospital OR psychologist");

    final googleMapsUrl =
        "https://www.google.com/maps/search/$query/@$lat,$lng,14z";

    final uri = Uri.parse(googleMapsUrl);

    // 4️⃣ Launch Google Maps
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}