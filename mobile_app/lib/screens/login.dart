import 'package:flutter/material.dart';
import 'layout.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _State();
}

class _State extends State<Login> {
  static const String DEFAULT_EMAIL = "Email";
  static const String DEFAULT_PASSWORD = "Password";

  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.indigo[300],
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50, bottom: 12),
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 25),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
              child: _editableUsername(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
              child: _editablePassword(),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 50, top: 0, bottom: 20),
                  child: Text(
                    "Don't have an account? Sign up!",
                    style: TextStyle(fontSize: 12),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 60.0, right: 60.0),
              child: Divider(color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 50, left: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: Icon(Icons.facebook, size: 50,), onPressed: () {  },),
                  IconButton(icon: Icon(Icons.facebook, size: 50,), onPressed: () {  },),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //Widget used for editable alarm title
  Widget _editableUsername() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          labelText: DEFAULT_EMAIL,
          floatingLabelBehavior: FloatingLabelBehavior.never),
    );
  }

  Widget _editablePassword() {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          labelText: DEFAULT_PASSWORD,
          floatingLabelBehavior: FloatingLabelBehavior.never),
    );
  }
}
/*TextButton(
onPressed: () {
Navigator
    .of(context)
    .pushReplacement(MaterialPageRoute(builder: (BuildContext context) => Layout()));
},*/
