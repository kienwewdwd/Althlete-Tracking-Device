import 'dart:convert';

import 'package:athlete_tracking/Data_from_ESP/temphumi.dart';
import 'package:athlete_tracking/Widgets/heading_widget.dart';
import 'package:athlete_tracking/constrants.dart';
import 'package:athlete_tracking/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:web_socket_channel/io.dart';
import 'package:firebase_database/firebase_database.dart';

// const String esp_url = 'ws://192.168.99.100:1509';

class TextScreen extends StatefulWidget {
  final String value1;
  final String value2;
  final String value3;
  final String value4;
  final String value5;
  final String value6;
  final double data_heartrate;
  final double data_distance;
  final double data_speedRunning;
  final double data_time;
  final double HR_average;
  final double Speed_average;

  const TextScreen(
      {Key? key,
      required this.value1,
      required this.value2,
      required this.value3,
      required this.value4,
      required this.value5,
      required this.value6,
      required this.data_heartrate,
      required this.data_distance,
      required this.data_speedRunning,
      required this.data_time,
      required this.HR_average,
      required this.Speed_average})
      : super(key: key);

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  // create the list chart
  List<_ChartData> chartData_HeartRate = [];
  List<_ChartData> chartData_Speed = [];

  // Connect the firebase
  final db4 = FirebaseFirestore.instance;

  // Create thge epoch to count time for data
  final epoch1 = ServerValue.timestamp;
  final epoch = DateTime.fromMillisecondsSinceEpoch(1);

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
  }

  @override
  Widget build(BuildContext context) {
    // add data in list to plot chart
    chartData_HeartRate
        .add(_ChartData(chartData_HeartRate.length, widget.data_heartrate));
    chartData_Speed
        .add(_ChartData(chartData_Speed.length, widget.data_speedRunning));

    return SizedBox(
      height: SizeConfig.blockSizeVertical * 90,
      child: Column(
        children: [
          // _builDaysBar(),
          _buiDashboardCards(),
        ],
      ),
    );
  }

  Widget _buiDashboardCards() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomColors.kBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: SizeConfig.blockSizeHorizontal * 60,
              height: SizeConfig.blockSizeVertical * 4,
              margin: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockSizeVertical * 2),
              decoration: BoxDecoration(
                color: CustomColors.kPrimaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(widget.value1,
                    style: TextStyle(
                        color: CustomColors.kLightColor,
                        fontSize: 27,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: HeadingWidget(
                text1: 'ACTIVITY',
                text2: '$today - $today1 - $today2',
              ),
            ),
            Container(
              height: SizeConfig.blockSizeVertical * 46, // 30% of screen
              width: SizeConfig.blockSizeHorizontal *
                  90, // 90% of total width of sreen
              margin: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockSizeVertical * 1),
              decoration: BoxDecoration(
                color: CustomColors.kBackgroundColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Stack(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 8,
                    children: [
                      buildcard(
                          iconPath: 'Images/assets/icons/running.svg',
                          text1: 'Running',
                          text2:
                              '${widget.data_speedRunning.toStringAsFixed(0)} Km/h',
                          context: context),
                      buildcard(
                          iconPath: 'Images/assets/icons/distance-9.svg',
                          text1: 'Distance',
                          text2: '${widget.data_distance.toStringAsFixed(0)} m',
                          context: context),
                      buildcard(
                        iconPath: 'Images/assets/icons/heart-rate-11.svg',
                        text1: 'Heart rate',
                        text2:
                            '${widget.data_heartrate.toStringAsFixed(0)} BPM',
                        context: context,
                      ),
                      buildcard(
                          iconPath:
                              'Images/assets/icons/95ba0f7164f52e5432f401a55e204753.svg',
                          text1: 'BMI',
                          text2: ' ${widget.value2}',
                          context: context)
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: HeadingWidget(
                text1: 'STATISTICS',
                text2: '$today - $today1 - $today2',
              ),
            ),
            _buildCard(
                color: CustomColors.kPrimaryColor,
                title: 'Calories Burned',
                subtitle:
                    '${calculateCaloriesBurned(double.parse(widget.value6), double.parse(widget.value5), double.parse(widget.value3), (widget.data_time / 60), widget.value4).toStringAsFixed(2)} kcal',
                time: '$today4:$today5',
                iconPath: 'Images/assets/icons/calories-svgrepo-com.svg'),
            _buildCard(
                color: CustomColors.kPrimaryColor,
                title: 'Total Time',
                subtitle: '${widget.data_time.toString()} min',
                time: '$today4:$today5',
                iconPath: 'Images/assets/icons/total-time-consumption.svg'),
            _buildCard(
                color: CustomColors.kPrimaryColor,
                title: 'Average Speed',
                subtitle: '${widget.Speed_average.toStringAsFixed(0)} km/h',
                time: '$today4:$today5',
                iconPath: 'Images/assets/icons/speed-meter-1.svg'),
            _buildCard(
                color: CustomColors.kPrimaryColor,
                title: 'Average BPM',
                subtitle: '${widget.HR_average.toStringAsFixed(0)} BPM ',
                time: '$today4:$today5',
                iconPath: 'Images/assets/icons/heart-rate-11.svg'),
          ]),
        ),
      ),
    );
  }

  Container _buildCard(
      {required Color color,
      required String title,
      required String subtitle,
      required String time,
      required String iconPath}) {
    return Container(
      width: SizeConfig.blockSizeHorizontal * 90,
      margin: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeVertical * 1.2),
              child: SvgPicture.asset(
                iconPath,
                height: SizeConfig.blockSizeVertical * 5,
                color: CustomColors.kLightColor,
              ),
            ),
          ),
          SizedBox(width: 15.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 1),
              Text(
                subtitle,
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0),
              ),
            ],
          ),
          Expanded(child: Container()),
          Text(
            time,
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 15.0),
          )
        ],
      ),
    );
  }

  Card buildcard(
      {String? iconPath,
      String? text1,
      String? text2,
      required BuildContext context}) {
    return Card(
      color: CustomColors.kBackgroundColor,
      child: Container(
        width: double.infinity,
        margin:
            EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 1),
        decoration: BoxDecoration(
            color: CustomColors.kPrimaryColor,
            borderRadius: BorderRadius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Column(
              children: [
                SvgPicture.asset(
                  iconPath!,
                  height: 50,
                  color: CustomColors.kLightColor,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  text1!,
                  style: TextStyle(
                    color: CustomColors.kLightColor,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  text2!,
                  style: CustomTextStyle.metricTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Container _builDaysBar() {
    return Container(
      margin: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical * 2,
        bottom: SizeConfig.blockSizeVertical * 2,
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Today',
            style: CustomTextStyle.dayTabBarStyleActive,
          ),
          Text(
            'Week',
            style: CustomTextStyle.dayTabBarStyleActive,
          ),
          Text(
            'Month',
            style: CustomTextStyle.dayTabBarStyleActive,
          ),
          Text(
            'Year',
            style: CustomTextStyle.dayTabBarStyleActive,
          ),
        ],
      ),
    );
  }

// Calculte the average for Hear rate or speed
  double calculateAverage(List<_ChartData> chartData) {
    double sum = 0.0;
    int count = chartData.length;

    for (_ChartData data in chartData) {
      if (data.data != null) {
        sum += data.data!;
      }
    }
    if (count > 0) {
      return sum / count;
    } else {
      return 0.0;
    }
  }
}

class _ListHeartRate {
  _ListHeartRate(this.data);
  final double data;
}

class _ChartData {
  _ChartData(this.time, this.data);
  final int? time;
  final double? data;
}
