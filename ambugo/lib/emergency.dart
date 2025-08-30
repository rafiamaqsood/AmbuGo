import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyPage extends StatelessWidget {
  final String regNo; // e.g. AMB-001
  const EmergencyPage({super.key, required this.regNo});

  // 🔹 Check & Request Location Permission
  Future<Position> _determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Location services are disabled.")),
      );
      return Future.error("Location services are disabled.");
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Location permission denied.")),
        );
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Location permanently denied. Enable in settings."),
        ),
      );
      return Future.error("Location permission permanently denied");
    }

    // ✅ Permission granted
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // 🚨 Send Emergency
  Future<void> sendEmergency(BuildContext context) async {
    try {
      print("🚨 Sending emergency for $regNo");

      Position pos = await _determinePosition(context);

      final dbRef = FirebaseDatabase.instance.ref("emergencies/$regNo");
      await dbRef.set({
        "lat": pos.latitude,
        "lng": pos.longitude,
        "time": DateTime.now().toIso8601String(),
        "status": "active", // 🚑 Emergency ON
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚑 Emergency sent!")),
      );
    } catch (e) {
      print("❌ Failed to send emergency: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ✅ Clear Emergency
  Future<void> clearEmergency(BuildContext context) async {
    try {
      final dbRef = FirebaseDatabase.instance.ref("emergencies/$regNo");
      await dbRef.update({
        "status": "cleared", // ✅ Emergency OFF
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Emergency cleared!")),
      );
    } catch (e) {
      print("❌ Failed to clear emergency: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Emergency - $regNo")),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => sendEmergency(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text(
                  "🚨 EMERGENCY",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              const SizedBox(height:20),
              ElevatedButton(
                onPressed: () => clearEmergency(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text(
                  "✅ CLEAR EMERGENCY",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}