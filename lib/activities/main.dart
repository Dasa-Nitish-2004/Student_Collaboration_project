import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:scolab/activities/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: AnimatedSplashScreen(
          splash: 'assets/imgs/appIcon.png',
          duration: 3000,
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.white,
          nextScreen: MyHomePage(title: 'Flutter Demo Home Page'),
          // pageTransitionType: PageTransitionType.scale,
        ));
  }
}

// const MyHomePage(title: 'Flutter Demo Home Page'),