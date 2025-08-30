// ----------------- Login Page -----------------
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'emergency.dart';
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final regController = TextEditingController();


  final dbRef = FirebaseDatabase.instance.ref("ambulances");

  Future<void> loginAmbulance() async {
    String regNo = regController.text.trim();


    DatabaseEvent event = await dbRef.child(regNo).once();
    if (event.snapshot.exists) {
      var data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data["verified"] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ambulance not verified yet!")));
        return;
      }

      try {


        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => EmergencyPage(regNo: regNo)));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Login failed: $e")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid reg number!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
            TextField(controller: regController, decoration:InputDecoration(labelText: "Registration No",labelStyle: TextStyle(
              color: Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(21),
              borderSide: BorderSide(
                  color: Colors.green,
                  width: 2
              )
            ))),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: loginAmbulance, child: const Text("Login",style: TextStyle(fontSize: 30,color: Colors.white),))
          ]),
        ),
      ),
    );
  }
}