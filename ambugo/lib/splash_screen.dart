// ----------------- Splash Screen -----------------
import 'package:flutter/material.dart';
import 'author_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds:5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AuthPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF58CC02), // ✅ Duolingo Green
      body: Center(
        child: Text(
          "AmbuGo 🚑",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}