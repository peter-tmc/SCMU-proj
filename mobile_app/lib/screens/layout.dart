import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/alarm.dart';
import 'package:mobile_app/screens/insights.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'alarm-detail.dart';
import 'alarms.dart';
import '../globals.dart' as globals;
class Layout extends StatefulWidget {
  Layout({Key? key}) : super(key: key);

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  static const ICON_SIZE = 40.0;
  int currentIndex = 0;

  Widget? alarmsScreen;
  Widget? insightsScreen;
  PageController? _pageController;
  int currentId = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: currentIndex);
    super.initState();
  }

  /*getAlarmsFromCache() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    List<String> alarmsListJson = _prefs.getStringList("alarms") ?? List.empty();
    if (alarmsListJson.isNotEmpty) {
      List<Alarm> aux = List.empty(growable: true);
      aux.add(
          //Alarm(alarmId: '123', date: DateTime.now().toString(), time: DateTime.now().toString()));
      for (var str in alarmsListJson) {
        aux.add(Alarm.fromJson(jsonDecode(str)));
      }
      setState(() {
        globals.alarmsList = aux;
      });
    } else {
      List<Alarm> aux = List.empty(growable: true);
      aux.add(
          //Alarm(alarmId: '123', date: DateTime.now().toString(), time: DateTime.now().toString()));
      setState(() {
        globals.alarmsList = aux;
      });
    }
  }*/

  List<Widget> renderCurrentPage() {
    List<Widget> widgets = <Widget>[];

    alarmsScreen = Alarms();
    widgets.add(alarmsScreen!);

    insightsScreen = Insights();
    widgets.add(insightsScreen!);

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // This allow the scroll to display whats below the appBar
      extendBody: false,
      backgroundColor: Color(0xFFFCF7F8),
      body: PageTransitionSwitcher(
        duration: Duration(milliseconds: 500),
        transitionBuilder: (widget, anim1, anim2) {
          return FadeTransition(
            opacity: anim1,
            child: widget,
          );
        },
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: renderCurrentPage(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Theme.of(context).secondaryHeaderColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: ICON_SIZE,
        backgroundColor: Colors.indigo[800],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            _pageController!.jumpToPage(currentIndex);
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: currentIndex == 0
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[500],
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.alarm,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.alarm,
                      ),
                    ),
              label: ""),
          BottomNavigationBarItem(
              icon: currentIndex == 1
                  ? Container(
                      decoration: BoxDecoration(
                        color:  Colors.indigo[500],
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.bed,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.bed,
                    ),
              label: ""),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  async{
          String currentTime = TimeOfDay.now().hour.toString()+":"+ TimeOfDay.now().minute.toString();
          String currentDate =  DateFormat('dd/mm/yyyy').format(DateTime.now());
          //TODO MAKE THIS NO DUMB
          Alarm alarm = await Navigator.push(context,  MaterialPageRoute(builder: (context) => AlarmDetails(id: currentId, alarm: Alarm(alarmId: currentId.toString(), time: currentTime, date: currentDate),)));
          globals.alarmsList.add(alarm);
          setState(() {
            currentId++;
          });


        },
        backgroundColor: Colors.indigo,

        child: Icon(Icons.add, color: Colors.white, size: 50),
      ),
    );
  }
}
