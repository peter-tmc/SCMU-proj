import 'package:flutter/material.dart';
import 'package:mobile_app/screens/layout.dart';
import 'package:mobile_app/screens/login.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: Layout(),
    );
  }
}

