import 'package:flutter/material.dart';
import 'package:mobile_app/models/alarm.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/screens/alarm-detail.dart';
import 'package:mobile_app/widgets/alarm.dart';
import 'package:mobile_app/widgets/customAppBar.dart';
import '../globals.dart' as globals;

class Alarms extends StatefulWidget {
  const Alarms({Key? key}) : super(key: key);

  @override
  State<Alarms> createState() => _State();
}

class _State extends State<Alarms> {
  List<Alarm> alarmsList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    getAlarmsFromCache();
  }

  getAlarmsFromCache() async {
    List<Alarm>? aux = globals.alarmsList;

    setState(() {
      alarmsList = aux;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String hours =
        DateFormat.H().format(now) + "H" + DateFormat('mm').format(now);
    return SafeArea(
      child: Column(
        children: [
          CustomAppBar(),
          Expanded(
            child: alarmsList.isNotEmpty
                ? ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: alarmsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      Alarm alarm = alarmsList[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 10, 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: AlarmCard(
                                alarm: alarm,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                splashRadius: 10,
                                onPressed: () {
                                  setState(() {
                                    globals.alarmsList.remove(alarm);
                                  });
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : SizedBox(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "No alarms",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: () async {
                  String currentTime = DateFormat.H().format(DateTime.now()) +
                      ":" +
                      DateFormat('mm').format(DateTime.now());
                  String currentDate =
                      DateFormat('dd/MM/yyyy').format(DateTime.now());
                  //TODO MAKE THIS NOT DUMB
                  Alarm alarm = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AlarmDetails(
                                id: globals.currentId,
                                alarm: Alarm(
                                    alarmId: globals.currentId.toString(),
                                    time: currentTime,
                                    date: currentDate),
                              )));
                  globals.alarmsList.add(alarm);
                  setState(() {
                    globals.currentId++;
                  });
                },
                backgroundColor: Colors.indigo,
                child: Icon(Icons.add, color: Colors.white, size: 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
