library mobile_app.globals;

import 'package:flutter/cupertino.dart';

import 'models/alarm.dart';

List<Alarm> alarmsList = List.empty(growable: true);
int currentId = 0;