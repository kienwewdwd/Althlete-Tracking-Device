import 'package:athlete_tracking/Widgets/indicator_widget.dart';
import 'package:athlete_tracking/constrants.dart';
import 'package:athlete_tracking/size_config.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityPieChart extends StatefulWidget {
  const ActivityPieChart({super.key});

  @override
  State<ActivityPieChart> createState() => _ActivityPieChartState();
}                            

class _ActivityPieChartState extends State<ActivityPieChart> {
  int? toucheIndex;
  @override
  Widget build(BuildContext context) {                     
    return Container(
      height: SizeConfig.blockSizeHorizontal * 40,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: SizeConfig.blockSizeHorizontal * 60,
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 1.0,
                  centerSpaceRadius: 50,
                  sections: showingSections(),
                  startDegreeOffset: 30,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event,
                        PieTouchResponse? pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          toucheIndex = -1;
                          return;
                        } else {
                          toucheIndex = pieTouchResponse
                              .touchedSection?.touchedSectionIndex;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical * 3),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Indicator(
                      color: CustomColors.kPrimaryColor,
                      iconPath: 'Images/assets/icons/running.svg',
                      title: 'RUNNING',
                      subtitle: '10 KM',
                    ),
                    Indicator(
                      color: CustomColors.kCyanColor,
                      iconPath: 'Images/assets/icons/bike.svg',
                      title: 'CYCLING',
                      subtitle: '10 KM',
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Indicator(
                      color: CustomColors.kLightPinkColor,
                      iconPath: 'Images/assets/icons/coffee.svg',
                      title: 'SWIMMING',
                      subtitle: '',
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = 3 == toucheIndex;
      final double radius = isTouched ? 30 : 20;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: CustomColors.kLightPinkColor,
            value: 2,
            title: "",
            radius: radius,
          );
        case 1:
          return PieChartSectionData(
            color: CustomColors.kPrimaryColor,
            value: 2,
            title: '',
            radius: radius,
          );
        case 2:
          return PieChartSectionData(
            color: CustomColors.kCyanColor,
            value: 33.33,
            title: "",
            radius: radius,
          );
        default:
          return PieChartSectionData(
            color: Colors.transparent,
            value: 0,
            title: "",
            radius: 0,
          );
      }
    });
  }
}
