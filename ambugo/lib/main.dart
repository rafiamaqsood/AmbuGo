// pubspec.yaml (add these dependencies)
// dependencies:
//   flutter:
//     sdk: flutter
//   firebase_core: ^2.24.2
//   firebase_auth: ^4.15.3
//   firebase_database: ^10.4.3
//   geolocator: ^10.1.0

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart';

// 🚀 MAIN
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmbuGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF7F9F8), // background
        primaryColor: const Color(0xFF58CC02), // Duolingo green

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF58CC02),
          primary: const Color(0xFF58CC02), // primary green
          secondary: const Color(0xFF89E219), // light green
          error: const Color(0xFFFF4B4B), // error red
          background: const Color(0xFFF7F9F8), // background
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF58CC02),
          foregroundColor: Colors.white,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58CC02),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),),
      home: const SplashScreen(),
    );
  }
}

// // ----------------- Splash Screen -----------------
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 10), () {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => const AuthPage()));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//           child: Text("🚑 My Ambulance App",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
//     );
//   }
// }
//
// // ----------------- Auth Page -----------------
// class AuthPage extends StatelessWidget {
//   const AuthPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                     context, MaterialPageRoute(builder: (_) => RegisterPage()));
//               },
//               child: const Text("Register")),
//           ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                     context, MaterialPageRoute(builder: (_) => LoginPage()));
//               },
//               child: const Text("Login")),
//         ]),
//       ),
//     );
//   }
// }
//
// // ----------------- Register Page -----------------
// class RegisterPage extends StatefulWidget {
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends State<RegisterPage> {
//   final regController = TextEditingController();
//   final chassisController = TextEditingController();
//   final emailController = TextEditingController();
//   final passController = TextEditingController();
//
//   final dbRef = FirebaseDatabase.instance.ref("ambulances");
//
//   Future<void> registerAmbulance() async {
//     String regNo = regController.text.trim();
//     String chassis = chassisController.text.trim();
//     String email = emailController.text.trim();
//     String pass = passController.text.trim();
//
//     DatabaseEvent event = await dbRef.child(regNo).once();
//     if (event.snapshot.exists) {
//       var data = Map<String, dynamic>.from(event.snapshot.value as Map);
//
//       if (data["verified"] == true) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text("Already registered!")));
//         return;
//       }
//
//       if (data["chassis_no"] == chassis) {
//         // ✅ Create FirebaseAuth user
//         try {
//           await FirebaseAuth.instance
//               .createUserWithEmailAndPassword(email: email, password: pass);
//
//           // ✅ Update ambulance verified
//           await dbRef.child(regNo).update({"verified": true, "createdAt": DateTime.now().toString()});
//
//           Navigator.pushReplacement(
//               context, MaterialPageRoute(builder: (_) => EmergencyPage(regNo: regNo)));
//         } catch (e) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text("Error: $e")));
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Chassis number mismatch!")));
//       }
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Invalid reg number!")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Register Ambulance")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(children: [
//           TextField(controller: regController, decoration: const InputDecoration(labelText: "Registration No (e.g. AMB-001)")),
//           TextField(controller: chassisController, decoration: const InputDecoration(labelText: "Chassis No")),
//           TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
//           TextField(controller: passController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
//           const SizedBox(height: 20),
//           ElevatedButton(onPressed: registerAmbulance, child: const Text("Register"))
//         ]),
//       ),
//     );
//   }
// }
//
// // ----------------- Login Page -----------------
// class LoginPage extends StatefulWidget {
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final regController = TextEditingController();
//   final emailController = TextEditingController();
//   final passController = TextEditingController();
//
//   final dbRef = FirebaseDatabase.instance.ref("ambulances");
//
//   Future<void> loginAmbulance() async {
//     String regNo = regController.text.trim();
//     String email = emailController.text.trim();
//     String pass = passController.text.trim();
//
//     DatabaseEvent event = await dbRef.child(regNo).once();
//     if (event.snapshot.exists) {
//       var data = Map<String, dynamic>.from(event.snapshot.value as Map);
//
//       if (data["verified"] != true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Ambulance not verified yet!")));
//         return;
//       }
//
//       try {
//         await FirebaseAuth.instance
//             .signInWithEmailAndPassword(email: email, password: pass);
//
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (_) => EmergencyPage(regNo: regNo)));
//       } catch (e) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Login failed: $e")));
//       }
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Invalid reg number!")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(children: [
//           TextField(controller: regController, decoration: const InputDecoration(labelText: "Registration No")),
//           TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
//           TextField(controller: passController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
//           const SizedBox(height: 20),
//           ElevatedButton(onPressed: loginAmbulance, child: const Text("Login"))
//         ]),
//       ),
//     );
//   }
// }
//
// // ----------------- Emergency Page -----------------
// class EmergencyPage extends StatelessWidget {
//   final String regNo;
//   const EmergencyPage({super.key, required this.regNo});
//
//   Future<void> sendEmergency() async {
//     Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//
//     final dbRef = FirebaseDatabase.instance.ref("emergencies/$regNo");
//     await dbRef.set({
//       "lat": pos.latitude,
//       "lng": pos.longitude,
//       "time": DateTime.now().toString()
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Emergency - $regNo")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: sendEmergency,
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(40)),
//           child: const Text("🚨 EMERGENCY", style: TextStyle(fontSize: 24, color: Colors.white)),
//         ),
//       ),
//     );
//   }
// }
