import 'package:athlete_tracking/Widgets/acitviti_Piechart.dart';
import 'package:athlete_tracking/Widgets/heading_widget.dart';
import 'package:athlete_tracking/constrants.dart';
import 'package:athlete_tracking/size_config.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String esp_url = 'ws://192.168.99.100:1509';

class Metricscreen extends StatefulWidget {
  final double data_heartrate;
  final double data_distance;
  final double data_speedRunning;
  final double data_time;
  final List<dynamic> New_chartData_HeartRate;
  final List<dynamic> New_chartData_Speed;
  // final List<dynamic> New_chartData_ECG;

  const Metricscreen({
    Key? key,
    required this.data_heartrate,
    required this.data_distance,
    required this.data_speedRunning,
    required this.data_time,
    required this.New_chartData_HeartRate,
    required this.New_chartData_Speed,
    // required this.New_chartData_ECG
  }) : super(key: key);

  @override
  State<Metricscreen> createState() => _MetricscreenState();
}

class _MetricscreenState extends State<Metricscreen> {
  // create the list chart
  List<_ChartData> chartData_HeartRate = [];
  List<_ChartData> chartData_Speed = [];

  final List<bool> _selectedStyleChart = <bool>[false, true];
  bool vertical = false;
  // Intial Date Time
  int today = DateTime.now().day;

  int today1 = DateTime.now().month;

  int today2 = DateTime.now().year;

  int today3 = DateTime.now().weekday;

  int today4 = DateTime.now().hour;

  int today5 = DateTime.now().minute;

  // Option slyte chart
  static const List<Widget> icons = <Widget>[
    Icon(Icons.stacked_line_chart),
    Icon(Icons.area_chart),
  ];

  @override
  Widget build(BuildContext context) {
    chartData_HeartRate
        .add(_ChartData(chartData_HeartRate.length, widget.data_heartrate));
    chartData_Speed
        .add(_ChartData(chartData_Speed.length, widget.data_speedRunning));

    return Container(
      height: SizeConfig.blockSizeVertical * 82,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        color: CustomColors.kBackgroundColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: HeadingWidget(
                text1: 'LIVE CHART',
                text2: '$today - $today1 - $today2',
              ),
            ),
            ToggleButtons(
              direction: vertical ? Axis.vertical : Axis.horizontal,
              onPressed: (int index) {
                setState(() {
                  // The button that is tapped is set to true, and the others to false.
                  for (int i = 0; i < _selectedStyleChart.length; i++) {
                    _selectedStyleChart[i] = i == index;
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.blue[700],
              selectedColor: Colors.white,
              fillColor: CustomColors.kPrimaryColor,
              color: CustomColors.kPrimaryColor,
              isSelected: _selectedStyleChart,
              children: icons,
            ),
            Center(
              child: SfCartesianChart(
                plotAreaBorderWidth: 3,
                plotAreaBorderColor: CustomColors.kPrimaryColor,
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                ),
                trackballBehavior: TrackballBehavior(enable: true),
                legend: Legend(),
                title: ChartTitle(
                    text: 'Heart Rate Chart',
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                primaryXAxis: NumericAxis(title: AxisTitle(text: 'Index(n)')),
                primaryYAxis:
                    NumericAxis(title: AxisTitle(text: 'Heart rate(BPM)')),
                series: <ChartSeries<dynamic, int>>[
                  if (_selectedStyleChart[0])
                    StackedLineSeries<dynamic, int>(
                      enableTooltip: true,
                      dataSource: widget.New_chartData_HeartRate,
                      xValueMapper: (dynamic data, _) => data.time,
                      yValueMapper: (dynamic data, _) => data.data,
                      color: CustomColors.kPrimaryColor,
                    )
                  else
                    StackedAreaSeries<dynamic, int>(
                      enableTooltip: true,
                      dataSource: widget.New_chartData_HeartRate,
                      xValueMapper: (dynamic data, _) => data.time,
                      yValueMapper: (dynamic data, _) => data.data,
                      color: CustomColors.kPrimaryColor.withOpacity(0.65),
                    ),
                ],
              ),
            ),
            Center(
              child: SfCartesianChart(
                plotAreaBorderWidth: 3,
                plotAreaBorderColor: CustomColors.kPrimaryColor,
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                ),
                legend: Legend(),
                title: ChartTitle(
                    text: 'Speed Chart',
                    textStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                primaryXAxis: NumericAxis(title: AxisTitle(text: 'Index(n)')),
                primaryYAxis:
                    NumericAxis(title: AxisTitle(text: 'Speed(km/h)')),
                series: <ChartSeries<dynamic, int>>[
                  if (_selectedStyleChart[0])
                    StackedLineSeries<dynamic, int>(
                      enableTooltip: true,
                      dataSource: widget.New_chartData_Speed,
                      xValueMapper: (dynamic data, _) => data.time,
                      yValueMapper: (dynamic data, _) => data.data,
                      color: CustomColors.kPrimaryColor,
                    )
                  else
                    StackedAreaSeries<dynamic, int>(
                      enableTooltip: true,
                      dataSource: widget.New_chartData_Speed,
                      xValueMapper: (dynamic data, _) => data.time,
                      yValueMapper: (dynamic data, _) => data.data,
                      color: CustomColors.kPrimaryColor.withOpacity(0.65),
                    ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 30),
            //   child: HeadingWidget(
            //     text1: 'ECG CHART',
            //     text2: '$today - $today1 - $today2',
            //   ),
            // ),
            // Center(
            //   child: SfCartesianChart(
            //     plotAreaBorderWidth: 2,
            //     plotAreaBorderColor: CustomColors.kPrimaryColor,
            //     borderColor: CustomColors.kPrimaryColor,
            //     tooltipBehavior: TooltipBehavior(
            //       enable: true,
            //     ),
            //     legend: Legend(),
            //     title: ChartTitle(
            //         text: ' ECG Signal',
            //         textStyle: TextStyle(
            //             color: Colors.black, fontWeight: FontWeight.bold)),
            //     primaryXAxis: NumericAxis(title: AxisTitle(text: 'Index(n)')),
            //     primaryYAxis: NumericAxis(title: AxisTitle(text: 'ECG Signal')),
            //     series: <ChartSeries<dynamic, int>>[
            //       StackedLineSeries<dynamic, int>(
            //         enableTooltip: true,
            //         dataSource: widget.New_chartData_ECG,
            //         xValueMapper: (dynamic data, _) => data.time,
            //         yValueMapper: (dynamic data, _) => data.data,
            //         color: CustomColors.kPrimaryColor,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.time, this.data);
  final int? time;
  final double? data;
}
