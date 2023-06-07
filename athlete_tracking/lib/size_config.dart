import 'package:flutter/material.dart';

// This will be used to create responsive UI. Check out the link in description for medium article for more details after the video :)

class SizeConfig {
 static late MediaQueryData _mediaQueryData;
 static late  double screenWidth;
 static late double screenHeight;
 static late double blockSizeHorizontal;
 static late double blockSizeVertical;


 void init(BuildContext context) {
  _mediaQueryData = MediaQuery.of(context);
  screenWidth = _mediaQueryData.size.width;
  screenHeight = _mediaQueryData.size.height;
  blockSizeHorizontal = screenWidth / 100;
  blockSizeVertical = screenHeight / 100;
 }
}