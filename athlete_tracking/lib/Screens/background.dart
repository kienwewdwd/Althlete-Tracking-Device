import 'package:athlete_tracking/Get_infor/Get_information.dart';
import 'package:athlete_tracking/Widgets/heading_widget.dart';
import 'package:athlete_tracking/constrants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HomePage11()),
    );
  }

  Widget _buildFullscreenImage(String nameImage) {
    return Column(
      children: [
        Image.asset(
          nameImage,
          fit: BoxFit.cover,
          height: 715,
          width: 500,
          alignment: Alignment.center,
        ),
      ],
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('Images/assets/icons/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            // const Icon(
            //   Icons.arrow_circle_down_rounded,
            //   color: CustomColors.kPrimaryColor,
            //   size: 35,
            // ),
            // SizedBox(
            //   width: 7,
            // ),
            Row(
              children: [
                Text(
                  "RunMinder",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CustomColors.kPrimaryColor,
                      fontSize: 30),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: IconButton(
                icon: Icon(Icons.arrow_forward_ios_outlined,
                    color: CustomColors.kPrimaryColor, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage11()),
                  );
                }),
          ),
        ],
      ),
      body: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        allowImplicitScrolling: true,
        autoScrollDuration: 3000,
        globalHeader: Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              // child: _buildImage('background4.png'),
            ),
          ),
        ),
        // globalFooter: SizedBox(
        //   width: double.infinity,
        //   height: 60,
        //   child: ElevatedButton(
        //     child: const Text(
        //       'Let\'s go right away!',
        //       style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        //     ),
        //     onPressed: () => _onIntroEnd(context),
        //   ),
        // ),
        pages: [
          PageViewModel(
            title: "The Ultimate Running Companion",
            body: " Experience Our State-of-the-Art Tracking Technology.",
            image: _buildFullscreenImage('Images/assets/icons/hinh1.png'),
            decoration: pageDecoration.copyWith(
              contentMargin: const EdgeInsets.symmetric(horizontal: 16),
              fullScreen: true,
              bodyFlex: 2,
              imageFlex: 3,
              safeArea: 100,
              titleTextStyle: TextStyle(
                color: CustomColors.kPrimaryColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
              pageColor: Colors.white60,
            ),
          ),
          PageViewModel(
            title: "Progress Tracking",
            body:
                "Achieve Your Fitness Goals with Our Powerful Running Tracker.",
            image: _buildFullscreenImage('Images/assets/icons/background4.png'),
            decoration: pageDecoration.copyWith(
                contentMargin: const EdgeInsets.symmetric(horizontal: 16),
                fullScreen: true,
                bodyFlex: 2,
                imageFlex: 3,
                safeArea: 100,
                titleTextStyle: TextStyle(
                    color: CustomColors.kPrimaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
                bodyTextStyle:
                    TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
                pageColor: Colors.white60),
          ),
          PageViewModel(
            title: "Workout Control",
            body: "Monitor Your Running Stats with Our Feature-Packed Tracker.",
            image: _buildFullscreenImage('Images/assets/icons/hinh2.png'),
            decoration: pageDecoration.copyWith(
                contentMargin: const EdgeInsets.symmetric(horizontal: 16),
                fullScreen: true,
                bodyFlex: 2,
                imageFlex: 3,
                safeArea: 100,
                titleTextStyle: TextStyle(
                    color: CustomColors.kPrimaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
                bodyTextStyle:
                    TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
                pageColor: Colors.white60),
          ),
          PageViewModel(
            title: "Effortless Monitoring",
            body:
                "Distance, Pace, and Calories Burned with Our Reliable Running Tracker.",
            image: _buildFullscreenImage('Images/assets/icons/hinh3.png'),
            decoration: pageDecoration.copyWith(
                contentMargin: const EdgeInsets.symmetric(horizontal: 16),
                fullScreen: true,
                bodyFlex: 2,
                imageFlex: 3,
                safeArea: 100,
                titleTextStyle: TextStyle(
                    color: CustomColors.kPrimaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
                bodyTextStyle:
                    TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
                pageColor: Colors.white60),
          ),
          PageViewModel(
            title: "Elevate Your Experience",
            body: "Real-Time Feedback and Comprehensive Performance Analysis.",
            image: _buildFullscreenImage('Images/assets/icons/hinh4.png'),
            decoration: pageDecoration.copyWith(
                contentMargin: const EdgeInsets.symmetric(horizontal: 16),
                fullScreen: true,
                bodyFlex: 2,
                imageFlex: 3,
                safeArea: 100,
                titleTextStyle: TextStyle(
                    color: CustomColors.kPrimaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
                bodyTextStyle:
                    TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
                pageColor: Colors.white60),
          ),
          PageViewModel(
            title: "Start Your Journey",
            body: "Keeping Tabs on Your Runs with Our Cutting-Edge Tracker.",
            image: _buildFullscreenImage('Images/assets/icons/hinh5.png'),
            decoration: pageDecoration.copyWith(
                contentMargin: const EdgeInsets.symmetric(horizontal: 16),
                fullScreen: true,
                bodyFlex: 2,
                imageFlex: 3,
                safeArea: 100,
                titleTextStyle: TextStyle(
                    color: CustomColors.kPrimaryColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
                bodyTextStyle:
                    TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
                pageColor: Colors.white60),
          ),
        ],
        onDone: () => _onIntroEnd(context),
        onSkip: () => _onIntroEnd(context), // You can override onSkip callback

        showSkipButton: false,
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: true,
        //rtl: true, // Display as right-to-left
        back: const Icon(
          Icons.arrow_back,
        ),
        skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(16),
        controlsPadding: kIsWeb
            ? const EdgeInsets.all(12.0)
            : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: const ShapeDecoration(
          color: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }
}
