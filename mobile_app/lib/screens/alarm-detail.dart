import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/alarm.dart';
import '../globals.dart' as globals;

class AlarmDetails extends StatefulWidget {
  const AlarmDetails({Key? key, required this.id, required this.alarm})
      : super(key: key);

  final int id;
  final Alarm alarm;

  @override
  State<AlarmDetails> createState() => _AlarmDetailsState();
}

class _AlarmDetailsState extends State<AlarmDetails> {
  /*------------------------------Alarm info------------------------------*/
  /* Name of the alarm */
  late String alarmTitle;

  /* Time of the alarm */
  late String timeOfAlarm;

  /*If allDays or any day in daysOfTheWeek is true this variable isn't considered.*/
  late String dateOfAlarm;

  /*Variable is true if the alarm should play everyDay, else otherwise.*/
  late bool allDays;

  /*
  * List of bool where each element represents a day of the week (Monday = index 0 for example).
  *
  * If the alarm is supposed to go off in a given day then the corresponding
  * day will be true.
  */
  late List<bool> daysOfTheWeek;

  /*List of bool where each element represents if an option in the app is turned
    on or off
  * 0 - Annoying alarm
  * 1 - Leveled sounds
  * 2 - LEDs*/
  late List<bool> switchOptions;

  @override
  void initState() {
    alarmTitle = widget.alarm.name.toString();
    timeOfAlarm = widget.alarm.time;
    dateOfAlarm = widget.alarm.date;
    allDays = widget.alarm.everyDay;
    daysOfTheWeek = widget.alarm.daysOfTheWeek.toList();
    switchOptions = [
      widget.alarm.annoyingAlarm,
      widget.alarm.soundLevel,
      widget.alarm.useLeds
    ];
    super.initState();
  }

  /*----------------------------------------------------------------------*/

  /*------------------------------State Variables------------------------------*/

  /*
   * This list is used in the following situation:
   * When the user turns on the option everyDay, all elements in daysOfTheWeek turn true
   * In case the user turns that option off then the daysOfTheWeek variable is
   * put in its previous state.
   */
  //TODO in case all days are true in this list  then every day turn off all days
  List<bool> previousState = [false, false, false, false, false, false, false];

  /*Tells if any text is being edited*/
  bool _isEditingText = false;

  /*---------------------------------------------------------------------------*/

  /*------------------------------Size Constants-------------------------------*/
  static const double OVERALL_LEFT_PADDING = 20.0;
  static const double CHECKBOX_LEFT_PADDING = 5.0;
  static const double DAYSOFTHEWEEK_ALL_PADDING = 15.0;

  /*---------------------------------------------------------------------------*/

  @override
  Widget build(BuildContext context) {
    //Current Time variables
    DateTime now = DateTime.now();
    String hours =
        DateFormat.H().format(now) + "H" + DateFormat('mm').format(now);

    return Material(
      color: Colors.indigo[300],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    OVERALL_LEFT_PADDING, 20.0, 35.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _editableAlarmTile()),
                    TextButton(
                        onPressed: () {
                          Alarm newAlarm = Alarm(
                              alarmId: widget.id.toString(),
                              name: alarmTitle,
                              time: timeOfAlarm,
                              date: dateOfAlarm,
                              annoyingAlarm: switchOptions[0],
                              soundLevel: switchOptions[1],
                              useLeds: switchOptions[2],
                              everyDay: allDays,
                              daysOfTheWeek: daysOfTheWeek);
                          Navigator.pop(context, newAlarm);
                        },
                        child: Text('SAVE',
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.black)))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    OVERALL_LEFT_PADDING, 20.0, 35.0, 0.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("Time: ", style: TextStyle(fontSize: 20.0)),
                          _editableAlarmTime()
                        ],
                      ),
                      if (daysOfTheWeek
                          .where((element) => element == true)
                          .toList()
                          .isEmpty)
                        Row(
                          children: [
                            Text("Date: ", style: TextStyle(fontSize: 20.0)),
                            _editableAlarmDate()
                          ],
                        ),
                    ]),
              ),
              if (!allDays)
                Padding(
                  padding: const EdgeInsets.only(left: DAYSOFTHEWEEK_ALL_PADDING, right: DAYSOFTHEWEEK_ALL_PADDING, top: DAYSOFTHEWEEK_ALL_PADDING),
                  child: Row(
                    children: [
                      _dayOfTheWeekIconButton("M", 0),
                      _dayOfTheWeekIconButton("T", 1),
                      _dayOfTheWeekIconButton("W", 2),
                      _dayOfTheWeekIconButton("T", 3),
                      _dayOfTheWeekIconButton("F", 4),
                      _dayOfTheWeekIconButton("S", 5),
                      _dayOfTheWeekIconButton("S", 6)
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    CHECKBOX_LEFT_PADDING, 0.0, 35.0, 0.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: allDays,
                      onChanged: (bool? value) {
                        setState(() {
                          allDays = value!;
                          if (allDays) {
                            previousState = List.from(daysOfTheWeek);
                            daysOfTheWeek.setAll(
                                0, [true, true, true, true, true, true, true]);
                          } else {
                            daysOfTheWeek = List.from(previousState);
                          }
                        });
                      },
                      activeColor: Colors.indigo,
                    ),
                    Text(
                      "Every day",
                      style: TextStyle(fontSize: 20.0),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    OVERALL_LEFT_PADDING, 20.0, 8.0, 15.0),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Text("Options:", style: TextStyle(fontSize: 20.0)),
                      ],
                    ),
                    _switchRow("Annoying alarm", 0),
                    _switchRow("Leveled sounds", 1),
                    _switchRow("LEDs", 2)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchRow(String name, int switchId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: TextStyle(fontSize: 18.0)),
        Switch(
          value: switchOptions[switchId],
          onChanged: (value) {
            setState(() {
              switchOptions[switchId] = !switchOptions[switchId];
            });
          },
          activeColor: Colors.indigo[900],
          inactiveThumbColor: Colors.indigo[200],
        ),
      ],
    );
  }

  Widget _dayOfTheWeekIconButton(String initial, int currentDay) {
    return Expanded(
      child: TextButton(
        style: (daysOfTheWeek[currentDay])
            ? ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.black12),
                shape: MaterialStateProperty.all(CircleBorder()),
                backgroundColor: MaterialStateProperty.all(Colors.indigo[900]),
              )
            : ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.black12),
                shape: MaterialStateProperty.all(CircleBorder()),
                backgroundColor: MaterialStateProperty.all(Colors.indigo[500])),
        onPressed: () {
          setState(() {
            daysOfTheWeek[currentDay] = !daysOfTheWeek[currentDay];
          });
        },
        child: Text(
          initial,
          style: TextStyle(fontSize: 20.0, color: Colors.white),
        ),
      ),
    );
  }

  Widget _editableAlarmDate() {
    return InkWell(
        onTap: () async {
          DateTime newDate = await showDatePicker(
            context: context,
            initialDate: DateTime(
                int.parse(dateOfAlarm.split("/")[2]),
                int.parse(dateOfAlarm.split("/")[1]),
                int.parse(dateOfAlarm.split("/")[0])),
            firstDate: DateTime(2022),
            lastDate: DateTime(2025),
          ) as DateTime;
          setState(() {
            dateOfAlarm = DateFormat("dd/MM/yyy").format(newDate);
          });
        },
        child: Text(dateOfAlarm, style: TextStyle(fontSize: 20.0)));
  }

  Widget _editableAlarmTime() {
    return InkWell(
        onTap: () async {
          TimeOfDay newTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: int.parse(timeOfAlarm.split(":")[0]),
                minute: int.parse(timeOfAlarm.split(":")[1])),
          ) as TimeOfDay;
          setState(() {
            timeOfAlarm = DateFormat('H')
                    .format(DateTime(0, 0, 0, newTime.hour, newTime.minute)) +
                ":" +
                DateFormat('mm')
                    .format(DateTime(0, 0, 0, newTime.hour, newTime.minute));
          });
        },
        child: Text(timeOfAlarm, style: TextStyle(fontSize: 20.0)));
  }

  //Widget used for editable alarm title
  Widget _editableAlarmTile() {
    TextEditingController _editingController =
        TextEditingController(text: alarmTitle);

    if (_isEditingText) {
      return Center(
          child: TextField(
        onSubmitted: (newValue) {
          setState(() {
            alarmTitle = newValue;
            _isEditingText = false;
          });
        },
        autofocus: true,
        controller: _editingController,
      ));
    }
    return InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
          });
        },
        child: Text(
          alarmTitle,
          style: TextStyle(fontSize: 30),
        ));
  }
}
