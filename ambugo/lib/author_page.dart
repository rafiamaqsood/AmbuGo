import 'package:flutter/material.dart';
import 'Registration.dart';
import 'login.dart';
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ambugo")),
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => RegisterPage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: const Text("Register",style: TextStyle(fontSize: 30,color: Colors.white),),
                    )),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => LoginPage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: const Text("Login",style: TextStyle(fontSize: 30,color: Colors.white),),
                    )),
              ),
            ]),
          ),
        ),
    );
  }
}