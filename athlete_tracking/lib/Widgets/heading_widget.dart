
import 'package:athlete_tracking/constrants.dart';
import 'package:athlete_tracking/size_config.dart';
import 'package:flutter/material.dart';

class HeadingWidget extends StatelessWidget {
  

  final String? text1;
  final String? text2;
  HeadingWidget({this.text1, this.text2});

  @override
  Widget build(BuildContext context) {
    return Container(

      width: SizeConfig.blockSizeVertical*90,
      margin: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeHorizontal*2),
      child: Row(
        children: [
          Text(
            text1!,
            style: TextStyle(
              color: CustomColors.kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ) ,
          ),
          Expanded(
            child: Container(),
          ),
          Text(
            text2!,
            style: TextStyle(
              color: CustomColors.kLightColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ) ,
          ),
        ],
      ),

    );
  }
}