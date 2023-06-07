import 'dart:convert';

import 'package:athlete_tracking/Data_from_ESP/temphumi.dart';
import 'package:athlete_tracking/Get_infor/Get_information.dart';
import 'package:athlete_tracking/Screens/main_Screen.dart';
import 'package:athlete_tracking/Screens/metric_screen.dart';
import 'package:athlete_tracking/constrants.dart';
import 'package:athlete_tracking/size_config.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_socket_channel/io.dart';

const String esp_url = 'ws://192.168.99.100:1509';

class HomeScreen extends StatefulWidget {
  final String value;
  final double value2;
  final String value3;
  final String value4;
  final String value5;
  final String value6;
  const HomeScreen({
    Key? key,
    required this.value,
    required this.value2,
    required this.value3,
    required this.value4,
    required this.value5,
    required this.value6,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Websocket
  bool isLoaded = false;
  String msg = '';
  DataRunning dht = DataRunning(0, 0, 0, 0, 0, 0, 0);
  final channel = IOWebSocketChannel.connect(esp_url);

  // Create the list
  List<_ChartData> chartData_HeartRate = [];
  List<_ChartData> chartData_Speed = [];
  List<_ChartData> chartData_ECG = [];
  List<_ChartData> New_chartData_ECG = [];

  // Tab
  int _currentIndex = 0;
  int Second = DateTime.now().second;
  // Create the database
  final database = FirebaseDatabase.instance.reference();

  // Intial Date Time
  int today = DateTime.now().day;
  int today1 = DateTime.now().month;
  int today2 = DateTime.now().year;
  int today3 = DateTime.now().weekday;
  int today4 = DateTime.now().hour;
  int today5 = DateTime.now().minute;

  @override
  void initState() {
    super.initState();
    // super.initState();
    channel.stream.listen(
      (message) {
        channel.sink.add('Flutter received $message');
        if (message == "connected") {
          print('Received from MCU: $message');
          if (!mounted) return;
          setState(() {
            msg = message;
          });
        } else {
          print('Received from MCU: $message');
          // {'tempC':'30.50','humi':'64.00'}
          Map<String, dynamic> json = jsonDecode(message);
          if (!mounted) return;
          setState(() {
            dht = DataRunning.fromJson(json);
            isLoaded = true;
          });
        }
        //channel.sink.close(status.goingAway);
      },
      onDone: () {
        //if WebSocket is disconnected
        print("Web socket is closed");
        if (!mounted) return;
        setState(() {
          msg = 'disconnected';
          isLoaded = false;
        });
      },
      onError: (error) {
        print(error.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String value = widget.value;
    String value2 = widget.value2.toStringAsFixed(2);
    String value3 = widget.value3;
    String value4 = widget.value4;
    String value5 = widget.value5;
    String value6 = widget.value6;
    double data_heartrate = dht.heartRate;
    double data_distance = dht.distance;
    double data_speedRunning = dht.speedRunning;
    double data_time = dht.time_activity;
    chartData_HeartRate
        .add(_ChartData(chartData_HeartRate.length, dht.heartRate));
    List<dynamic> New_chartData_HeartRate = chartData_HeartRate;

    chartData_Speed.add(_ChartData(chartData_Speed.length, dht.speedRunning));
    List<dynamic> New_chartData_Speed = chartData_Speed;

    double HR_average = calculateAverage(chartData_HeartRate);
    double Speed_average = calculateAverage(chartData_Speed);

    // Add data into chart_ECG
    // chartData_ECG.add(_ChartData(chartData_ECG.length, dht.ECG_signal));
    // int max_length = 90; // Giá trị ngưỡng tối đa
    // if (chartData_ECG.length > max_length) {
    //   New_chartData_ECG = chartData_ECG.sublist(
    //     chartData_ECG.length - max_length,
    //     chartData_ECG.length,
    //   );
    // } else {
    //   New_chartData_ECG = chartData_ECG;
    // }
    // if (chartData_ECG.length > 1500) {
    //   chartData_ECG.removeRange(0, chartData_ECG.length);
    //   chartData_ECG.add(_ChartData(chartData_ECG.length, dht.ECG_signal));
    // }
    // List<dynamic> New_chartData_ECG1 = New_chartData_ECG;

    setState(() {});

    final tabs = [
      TextScreen(
          value1: value,
          value2: value2,
          value3: value3,
          value4: value4,
          value5: value5,
          value6: value6,
          data_heartrate: data_heartrate,
          data_distance: data_distance,
          data_speedRunning: data_speedRunning,
          data_time: data_time,
          HR_average: HR_average,
          Speed_average: Speed_average),
      Metricscreen(
        data_heartrate: data_heartrate,
        data_distance: data_distance,
        data_speedRunning: data_speedRunning,
        data_time: data_time,
        New_chartData_HeartRate: New_chartData_HeartRate,
        New_chartData_Speed: New_chartData_Speed,
      )
    ];

    // Sent data to database
    final data1 = database.child('/Tracking/User/${widget.value}');
    final databaseReference = FirebaseDatabase.instance.reference();

    data1.set({
      'DateTime': DateTime.now().toString(),
      'Running': '${dht.speedRunning.toStringAsFixed(0)} km/h',
      'Distance': '${dht.distance.toStringAsFixed(0)} m',
      'Heart rate': '${dht.heartRate.toStringAsFixed(0)} BPM',
      'BMI': widget.value2,
      'Age': widget.value3,
      'Sex': widget.value4,
      'Time Activity': '${dht.time_activity} minute'
    });
    final heartRateData = {
      'timestamp': DateTime.now().toUtc().toString(),
      'value': dht.heartRate.toStringAsFixed(0),
    };
    final distanceData = {
      'timestamp': DateTime.now().toUtc().toString(),
      'value': dht.distance.toStringAsFixed(0),
    };
    final speedData = {
      'timestamp': DateTime.now().toUtc().toString(),
      'value': dht.speedRunning.toStringAsFixed(0),
    };

    database
        .child(
            '/Tracking/History/${widget.value}/$today-$today1-$today2/HeartRateList')
        .push()
        .update(heartRateData);
    database
        .child(
            '/Tracking/History/${widget.value}/$today-$today1-$today2/DistanceList')
        .push()
        .update(distanceData);
    database
        .child(
            '/Tracking/History/${widget.value}/$today-$today1-$today2/SpeedList')
        .push()
        .update(speedData);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: CustomColors.kPrimaryColor, size: 30),
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => const HomePage11()),
              );
            }),
        title: SvgPicture.asset(
          'Images/assets/icons/dumbell.svg',
          height: SizeConfig.blockSizeHorizontal * 10,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.notifications,
              size: 30,
              color: CustomColors.kPrimaryColor,
            ),
          ),
        ],
      ),
      body: tabs[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: CustomColors.kPrimaryColor,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'Images/assets/icons/apps.svg',
              height: 30,
              color: Colors.grey,
            ),
            label: 'Activity',
            activeIcon: SvgPicture.asset(
              'Images/assets/icons/apps.svg',
              height: 30,
              color: CustomColors.kPrimaryColor,
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'Images/assets/icons/stats.svg',
              height: 30,
              color: Colors.grey,
            ),
            label: 'Stats',
            activeIcon: SvgPicture.asset(
              'Images/assets/icons/stats.svg',
              height: 30,
              color: CustomColors.kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Calculte the average for Hear rate or speed
  double calculateAverage(List<_ChartData> chartData) {
    double sum = 0.0;
    int count = 0;

    for (_ChartData data in chartData) {
      if (data.data != null && data.data != 0) {
        sum += data.data!;
        count++;
      }
    }

    if (count > 0) {
      return sum / count;
    } else {
      return 0.0;
    }
  }
}

double calculateCaloriesBurned(
    double? weight, double? height, double? age, double? t, String? gender) {
  // Calculate BMR
  double? bmr;
  if (gender == 'Male') {
    bmr = (13.75 * weight!) + (5 * height!) - (6.76 * age!) + 66;
  } else if (gender == 'Female') {
    bmr = (9.56 * weight!) + (1.85 * height!) - (4.68 * age!) + 655;
  }

  // Calculate calories burned
  double caloriesBurned = (bmr! / 24) * 7.0 * t!;
  // Note: We assume a MET of 4.0 for walking
  return caloriesBurned;
}

class _ChartData {
  _ChartData(this.time, this.data);
  final int? time;
  final double? data;
}
