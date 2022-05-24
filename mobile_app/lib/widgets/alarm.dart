import 'package:flutter/material.dart';
import 'package:mobile_app/models/alarm.dart';
import 'package:mobile_app/screens/alarm-detail.dart';

import '../screens/layout.dart';
import '../globals.dart' as globals;

class AlarmCard extends StatefulWidget {
  AlarmCard({
    Key? key,
    required this.alarm,
  }) : super(key: key);

  Alarm alarm;

  @override
  State<AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard>{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color:
                widget.alarm.isOn ? Colors.indigo.withOpacity(0.20) : Colors.red.withOpacity(0.20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: SizedBox(
                height: 37,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.alarm.time,
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () async {
                          Alarm changedAlarm = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AlarmDetails(
                                        id: int.parse(widget.alarm.alarmId),
                                        alarm: widget.alarm,
                                      )));
                          int id = globals.alarmsList.indexOf(widget.alarm);
                          globals.alarmsList.remove(widget.alarm);
                          globals.alarmsList.insert(id, changedAlarm);
                          widget.alarm = changedAlarm;
                          setState(() {});
                        },
                        icon: Icon(Icons.mode_edit, size: 20, color: Colors.black54),
                        splashRadius: 16)
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child: SizedBox(
                height: 37,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.alarm.name,
                      style: TextStyle(fontSize: 18),
                    ),
                    Row(
                      children: [
                        Switch(
                          value: widget.alarm.isOn,
                          onChanged: (bool value) {
                            setState(() {
                              widget.alarm.isOn = !widget.alarm.isOn;
                            });
                          },
                          activeColor: Colors.indigo,
                          inactiveThumbColor: Colors.red,

                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
              child: widget.alarm.everyDay || widget.alarm.daysOfTheWeek.where((element) => element == true).toList().isNotEmpty
                ?Row(
                  children: [
                    dayOfTheWeekTextCustomize("M ", widget.alarm.daysOfTheWeek[0]),
                    dayOfTheWeekTextCustomize("T ", widget.alarm.daysOfTheWeek[1]),
                    dayOfTheWeekTextCustomize("W ", widget.alarm.daysOfTheWeek[2]),
                    dayOfTheWeekTextCustomize("Q ", widget.alarm.daysOfTheWeek[3]),
                    dayOfTheWeekTextCustomize("F ", widget.alarm.daysOfTheWeek[4]),
                    dayOfTheWeekTextCustomize("S ", widget.alarm.daysOfTheWeek[5]),
                    dayOfTheWeekTextCustomize("S ", widget.alarm.daysOfTheWeek[6]),
                  ],
                )
                :Row(
                  children: [
                    Text(widget.alarm.date)
                  ],
                ),
            )
          ],
        ),
      ),
    );
  }
  Widget dayOfTheWeekTextCustomize(String text, bool isOn){
    if(isOn && widget.alarm.isOn){
      return Text(text, style: TextStyle(fontSize: 18, color: Colors.indigo[900]));
    }else if(isOn && !widget.alarm.isOn){
      return Text(text, style: TextStyle(fontSize: 18, color: Colors.red[900]));
    }
    else if(!isOn && widget.alarm.isOn){
      return Text(text, style: TextStyle(fontSize: 18, color: Colors.indigo[300]));
    }
    else{
      return Text(text, style: TextStyle(fontSize: 18, color: Colors.red[300]));
    }
  }
}
