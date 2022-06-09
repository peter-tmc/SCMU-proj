import 'package:flutter/material.dart';
import 'package:mobile_app/models/alarm.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/screens/alarm-detail.dart';
import 'package:mobile_app/widgets/alarm.dart';
import '../globals.dart' as globals;

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  State<CustomAppBar> createState() => _State();
}

class _State extends State<CustomAppBar> {
  List<Alarm> alarmsList = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width-35,
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight:  Radius.circular(30)),
        ),
      ),
    );
  }
}
