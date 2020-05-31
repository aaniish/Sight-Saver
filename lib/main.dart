import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_usage/app_usage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppUsage appUsage = new AppUsage();
  String apps = 'Unknown';
  String totalTime = 'Unknown';
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


  @override
  void initState() {
    super.initState();
    initPlatformState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }
  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
  }

  void getUsageStats() async {
    Timer.periodic(Duration(seconds: 2), (timer) async{
    try {
      DateTime endDate = new DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
      Map<String, double> usage = await appUsage.fetchUsage(startDate, endDate);
      usage.removeWhere((key,val) => val == 0);
      setState(() => apps = makeString(usage));

    }
    on AppUsageException catch (exception) {
      print(exception);

    }
    });
  }


  String makeString(Map<String, double> usage) {
    String result = '';
    usage.forEach((k,v) {
      String appName = k.split('.').last;
      String timeInMins = (v / 60).toStringAsFixed(2);
      result += '$appName : $timeInMins minutes\n';
    });
    return result;
  }

  double getTotalTime(Map<String, double> usage) {
    double total = 0;
    usage.forEach ((k,v) {
      double timeInMins = (v / 60);
      total = total + timeInMins;
    });
    double time = double.parse(total.toStringAsFixed(2));
    return time;
  }

  void getTotalUsage() async {
    Timer.periodic(Duration(seconds: 2), (timer) async{
      try {
        DateTime endDate = new DateTime.now();
        DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
        Map<String, double> usage = await appUsage.fetchUsage(startDate, endDate);
        usage.removeWhere((key,val) => val == 0);
        String timeWords = getTotalTime(usage).toString();
        setState(() => totalTime = 'Total Time: $timeWords minutes');

      }
      on AppUsageException catch (exception) {
        print(exception);
      }
    });
  }


  @override
  Widget build(BuildContext context) {


    return new MaterialApp(
      home: new Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Sight Saver'),
        ),
        body: new Container(
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Container (
                  padding: const EdgeInsets.all(30.0),
                  color: Colors.black,
                  child: new Container(
                    child: new Center(
                        child: new Column(
                            children : [
                              new Padding(padding: EdgeInsets.only(top: 5)),
                              new Text('Screen Time Data',
                                style: new TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Barlow",

                                ),),
                            ]
                        )
                    ),
                  )
              ),

              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  border: Border.all(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(
                      Radius.circular(10.0)
                  ),
                ),
                child:Text(apps,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0, // insert your font size here
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  border: Border.all(
                      color: Colors.blue,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0)
                  ),
                ),
                child:Text(totalTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0, // insert your font size here
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),


            ],
          ),
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: RaisedButton(
                padding: const EdgeInsets.all(20.0),
                color: Colors.greenAccent,
                onPressed: () {
                  getTotalUsage();
                  getUsageStats();//fun1
                  showNotification();
                },
                child:
                Text("Start Task"),
              ),
            ),
          ],
        ),
      ),
    );
  }
  showNotification() async {
    DateTime endDate = new DateTime.now();
    DateTime startDate = DateTime(
        endDate.year, endDate.month, endDate.day, 0, 0, 0);
    Map<String, double> usage = await appUsage.fetchUsage(startDate, endDate);
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    bool endLoop = true;
    while (endLoop) {
      if (getTotalTime(usage) > 300.0) {
        await flutterLocalNotificationsPlugin.show(0, 'Sight Saver Exercise',
            'Palming - You must generate heat with your hands by rubbing your hands together and cup your hands to put them over your closed eyes, which will relax them.',
            platform,
            payload: 'Exercise');
        endLoop = false;
      } else if (getTotalTime(usage) > 100.0) {
        await flutterLocalNotificationsPlugin.show(0, 'Sight Saver Exercise',
            'Eye Rolling - Take a minute to roll your eyes while using your device. Just close your eyes and roll them in circular motions.',
            platform,
            payload: 'Exercise');
        endLoop = false;
      }
    }
  }
}

