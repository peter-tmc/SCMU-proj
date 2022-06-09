import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/screens/insights.dart';
import 'alarms.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mobile_app/screens/login.dart';
import '../globals.dart' as globals;



class Layout extends StatefulWidget {
  const Layout({Key? key}) : super(key: key);

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
  void initState(){
    _pageController = PageController(initialPage: currentIndex);
    super.initState();
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if(globals.alarmsList.isNotEmpty){
        List a = globals.alarmsList.toList();

      }
      /*AudioPlayer player = AudioPlayer();
      ByteData bytes = await rootBundle.load('assets/audios/sound_alarm.mp3'); //load sound from assets
      Uint8List  soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      player.playBytes(soundbytes);*/
    });
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
                        color: Colors.indigo[500],
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
    );
  }
}
