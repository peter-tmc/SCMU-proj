import 'package:flutter/material.dart';

class Alarm {
  final String alarmId;
  final String name;
  final String date;
  final String time;
  final bool annoyingAlarm;
  final bool soundLevel;
  final List<bool>daysOfTheWeek;
  final bool everyDay;
  final bool useLeds;
  bool isOn;

  Alarm(
      {required this.alarmId,
      this.name = "New Alarm",
      required this.date,
      required this.time,
      this.annoyingAlarm = false,
      this.soundLevel = false,
      this.useLeds = false,
      this.isOn = true,
      this.everyDay = false,
      this.daysOfTheWeek = const [false,false,false,false,false,false,false]});

  Alarm.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        alarmId = json['alarmId'],
        date = json['date'],
        time = json['time'],
        annoyingAlarm = json['annoyingAlarm'],
        soundLevel = json['soundLevel'],
        useLeds = json['useLeds'],
        isOn = json['isOn'],
        everyDay = json['everyDay'],
        daysOfTheWeek = json['daysOfTheWeek'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'alarmId': alarmId,
        'date': date,
        'time': time,
        'annoyingAlarm': annoyingAlarm,
        'soundLevel': soundLevel,
        'useLeds': useLeds,
        'isOn': isOn,
        'everyDay': everyDay,
        'daysOfTheWeek': daysOfTheWeek
      };
}
