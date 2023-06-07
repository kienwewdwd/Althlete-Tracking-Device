
import 'package:athlete_tracking/Get_infor/Get_information.dart';
import 'package:athlete_tracking/Screens/background.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const String esp_url = 'ws://192.168.99.100:1509';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: MyApp(),
  )

      // MyApp()
      );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Athlete Tracking App ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: MyHomePage1(),
      // );
      home: const OnBoardingPage(),
    );
  }
}
