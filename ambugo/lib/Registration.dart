// ----------------- Register Page -----------------
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'emergency.dart';
class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final regController = TextEditingController();
  final chassisController = TextEditingController();


  final dbRef = FirebaseDatabase.instance.ref("ambulances");

  Future<void> registerAmbulance() async {
    String regNo = regController.text.trim();
    String chassis = chassisController.text.trim();


    DatabaseEvent event = await dbRef.child(regNo).once();
    if (event.snapshot.exists) {
      var data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data["verified"] == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Already registered!")));
        return;
      }

      if (data["chassis_no"] == chassis) {
        // ✅ Create FirebaseAuth user
        try {


          // ✅ Update ambulance verified
          await dbRef.child(regNo).update({"verified": true, "createdAt": DateTime.now().toString()});

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => EmergencyPage(regNo: regNo)));
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chassis number mismatch!")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid reg number!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Ambulance")),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(controller: regController, decoration:
                 InputDecoration( labelText: "Registration No (e.g. AMB-001)", labelStyle: TextStyle(
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
                  ), )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(controller: chassisController, decoration: InputDecoration(labelText: "Chassis No", labelStyle: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
                focusedBorder:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21),
                  borderSide: BorderSide(
                    color: Colors.green,
                    width: 2
                  )
                ),)),
              ),

              const SizedBox(height: 20),
              ElevatedButton(onPressed: registerAmbulance, child: const Text("Register",style: TextStyle(fontSize: 30,color: Colors.white),))
            ]),

        ),
      ),
    );
  }
}