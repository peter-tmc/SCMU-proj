library mobile_app.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'models/alarm.dart';

List<Alarm> alarmsList = List.empty(growable: true);

late BluetoothDevice devicebt;

late BluetoothConnection connection;